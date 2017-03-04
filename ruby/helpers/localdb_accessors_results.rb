# Module  Perseus                 - The namespace for all application code
# Module  LocalDBConnection       - Helper methods to access the LAN database
# Module  Competition             - Competition related methods
#
require 'sequel'
require 'pg'
require 'json'

# Results data getters/setters
#
module Perseus
  module LocalDBConnection
    module Results
      # Default route parameters
      @default_route = { wet_id: 0, grp_id: 0, route: 0 }

      # Notionally private methods
      private_class_method

      # Return a sequel object to fetch either __single__ or __multiple__ results
      #
      # OPTIMIZE: THE RANK FUNCTION DOES NOT WORK IF ONLY A SINGLE CLIMBER'S RESULTS ARE
      # RETRIEVED. WE'D NEED TO USE A POSTGRES VIEW TO PRESERVE RANKINGS...
      # AND IF WE'RE COING TO USE A VIEW THEN WE MAY BE ABLE TO DISPENSE WITH SOME OF THIS
      # ALSO WE NEED TO DEAL WITH THE GENERAL RESULT
      #
      def self.get_result params, order_by: 'result_rank'
        DB[:Results]
          .join(:Climbers, [:per_id])
          .where(params)
          .select(:per_id, :lastname, :firstname, :nation, :start_order,
                  :rank_prev_heat, :sort_values, :result_jsonb)
          .select_append {
            rank.function.over(
              partition: [:wet_id, :grp_id, :route],
              order: Perseus::IFSCBoulderModus.rank_generator
            ).as(:result_rank)
          }
          .order(order_by.to_sym)
      end

      # Check that a specified climber is identified by either their per_id or their start_number
      # within the round. Prefer the per_id if both are provided
      def self.query params
        args = Hash[@default_route.map { |k, v| [k, params[k].to_i || v] }]
        id   = params[:per_id].nil? ? :start_order : :per_id
        args.merge(id => params[id].to_i)
      end

      module_function

      # Helper method to delete a startlist or a person (use per_id as an optional
      # parameter to delete an individual rather than the complete list
      def delete params
        args          = Hash[@default_route.map { |k, v| [k, params[k].to_i || v] }]
        args[:per_id] = params[:per_id].to_i unless params[:per_id].nil?
        DB[:Results].where(args).delete
      end

      # Fetch results for a single person (i.e. for a single climber across the round)
      def result_person params
        args = query(params)
        get_result(args).first
      end

      # Fetch results for a collection of results (i.e. for a route)
      # Map the received parameters against the default parameters required for a collection
      # of results abd call the general accessor get_result
      def result_route params
        args = Hash[@default_route.map { |k, v| [k, params[k].to_i || v] }]
        get_result(args).all
      end

      # Update results for a __single__ competitor
      # Updates (a) the result_jsonb property for the specific set of results and (b) the
      # sort_values property used for ranking
      #
      # @params = {
      #   wet_id: 0, grp_id: 0, route: 0, per_id: 0,
      #   result_jsonb: { 'p1' => { 'a' => 2, 'b' => 1, 't' => 2 }}
      # }
      def update_single params
        args = query(params)
        data = params[:result_jsonb] || {}

        query = DB[:Results].where(args)

        new_result = Perseus::IFSCBoulderModus.merge(query.first[:result_jsonb], data)
        sort_array = Perseus::IFSCBoulderModus.sort_values(new_result)

        query.update(
          sort_values: Sequel.pg_array(sort_array),
          result_jsonb: Sequel.pg_jsonb(new_result)
        )
      end
    end
  end
end
