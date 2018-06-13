module Fox
  class FXTable
    ## why isn't this in Fox?
    unless instance_methods(true).include?("deselectRange")
      def deselectRange(sr, er, sc, ec, notify = false)
        changes = false
        for row in sr..er
          for col in sc..ec
            changes |= deselectItem(row, col, notify)
          end
        end
        return changes
      end
    end
  end
end
