module LearnOpen
  module Environments
      module ValidityChecker
        def open_readme(lesson)
          when_valid(lesson) do
            super
          end
        end

        def open_jupyter_lab(lesson, location, editor)
          when_valid(lesson) do
            super
          end
        end

        def open_lab(lesson, location, editor)
          when_valid(lesson) do
            super
          end
        end

        def when_valid(lesson, &block)
          if valid?(lesson)
            block.call
          else
            on_invalid(lesson)
          end
        end
      end
  end
end
