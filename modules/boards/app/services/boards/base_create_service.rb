# frozen_string_literal: true

module Boards
  class BaseCreateService < ::Grids::CreateService
    protected

    def instance(attributes)
      Boards::Grid.new(
        row_count: row_count_for_board,
        column_count: column_count_for_board,
        project: attributes[:project]
      )
    end

    def before_perform(params, _service_result)
      return super(params, _service_result) if grid_lacks_query?(params)

      create_query_result = create_query(params)

      return create_query_result if create_query_result.failure?

      super(params.merge(query_id: create_query_result.result.id), create_query_result)
    end

    def set_attributes_params(params)
      {}.tap do |grid_params|
        grid_params[:name] = params[:name]
        grid_params[:options] = options_for_grid(params)
        grid_params[:row_count] = row_count_for_board
        grid_params[:column_count] = column_count_for_board
        grid_params[:widgets] = options_for_widgets(params)
      end
    end

    def attributes_service_class
      BaseSetAttributesService
    end

    private

    def grid_lacks_query?(_params)
      false
    end

    def create_query(params)
      Queries::CreateService.new(user: User.current)
                            .call(create_query_params(params))
    end

    def create_query_params(params)
      {
        project: params[:project],
        name: query_name(params),
        filters: query_filters(params)
      }
    end

    def query_name(_params)
      raise 'Define the query name'
    end

    def query_filters(_params)
      raise 'Define the query filters'
    end

    def options_for_grid(params)
      {}.tap do |options|
        options[:attribute] = params[:attribute]
        options[:type] = params[:attribute] == 'basic' ? 'free' : 'action'
      end
    end

    def options_for_widgets(params)
      raise 'Define the options for the grid widgets'
    end

    def row_count_for_board
      1
    end

    def column_count_for_board
      4
    end
  end
end
