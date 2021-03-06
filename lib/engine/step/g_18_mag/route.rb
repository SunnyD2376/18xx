# frozen_string_literal: true

require_relative '../base'

module Engine
  module Step
    module G18Mag
      class Route < Route
        BUY_ACTION = %w[special_buy].freeze
        RAILCAR_BASE = [10, 10, 20, 20].freeze

        def actions(entity)
          return [] if !entity.operator? || entity.runnable_trains.empty? || !@game.can_run_route?(entity)

          if buyable_items(entity).empty?
            ACTIONS
          else
            ACTIONS + BUY_ACTION
          end
        end

        def setup
          super

          @round.rail_cars = []
        end

        def log_skip(entity)
          super unless entity.corporation?
        end

        def buyable_items(entity)
          return [] unless entity.minor?
          return [] unless entity.minor?
          return [] unless entity.cash >= item_cost

          items = []

          unless @round.rail_cars.include?('G&C')
            items << Item.new(description: 'Plus Train Upgrade [G&C]', cost: item_cost)
          end

          unless @round.rail_cars.include?('RABA')
            items << Item.new(description: "+#{@game.raba_delta(@game.phase)} Offboard Bonus [RABA]",
                              cost: item_cost)
          end

          items << Item.new(description: 'Mine Access [SNW]', cost: item_cost) unless @round.rail_cars.include?('SNW')

          items
        end

        def item_cost
          RAILCAR_BASE[@game.phase.current[:tiles].size - 1] + 10 * @round.rail_cars.size
        end

        def round_state
          {
            routes: [],
            rail_cars: [],
          }
        end

        def process_special_buy(action)
          item = action.item
          desc = item.description
          corp = case desc
                 when /G\&C/
                   @game.gc
                 when /RABA/
                   @game.raba
                 when /SNW/
                   @game.snw
                 end
          @round.rail_cars << corp.name

          action.entity.spend(item.cost, corp)
          @log << "#{action.entity.name} buys #{desc} for #{@game.format_currency(item.cost)}"
        end
      end
    end
  end
end
