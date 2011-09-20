module ActiveAdmin
  module Views
    module Pages

      class Index < Base

        def title
          active_admin_config.human_name.pluralize
        end

        def config
          index_config || default_index_config
        end

        # Render's the index configuration that was set in the
        # controller. Defaults to rendering the ActiveAdmin::Pages::Index::Table
        def main_content
          build_scopes

          if collection.any?
            render_index
          else
            if params[:q]
              render_empty_results
            else
              render_blank_slate
            end
          end
        end

        protected

        def build_scopes
          if active_admin_config.scopes.any?
            scopes_renderer active_admin_config.scopes
          end
        end

        # Creates a default configuration for the resource class. This is a table
        # with each column displayed as well as all the default actions
        def default_index_config
          @default_index_config ||= ::ActiveAdmin::PageConfig.new(:as => :table) do |display|
            id_column
            resource_class.content_columns.each do |col|
              column col.name.to_sym
            end
            default_actions
          end
        end

        # Returns the actual class for renderering the main content on the index
        # page. To set this, use the :as option in the page_config block.
        def find_index_renderer_class(symbol_or_class)
          case symbol_or_class
          when Symbol
            ::ActiveAdmin::Views.const_get("IndexAs" + symbol_or_class.to_s.camelcase)
          when Class
            symbol_or_class
          else
            raise ArgumentError, "'as' requires a class or a symbol"
          end
        end
        
        def render_blank_slate
          blank_slate_content = I18n.t("activeadmin.resources.#{active_admin_config.i18n_scope}.blank_slate.content",
            :default => :"active_admin.blank_slate.content",
            :resource_name => active_admin_config.human_name
          )
          if controller.action_methods.include?('new')
            txt = I18n.t("activeadmin.resources.#{active_admin_config.i18n_scope}.blank_slate.link",
              :default => :"active_admin.blank_slate.link")
            blank_slate_content += " " + link_to(txt, new_resource_path)
          end
          insert_tag(view_factory.blank_slate, blank_slate_content)
        end
        
        def render_empty_results
          empty_results_content = I18n.t("activeadmin.resources.#{active_admin_config.i18n_scope}.pagination.empty",
            :default => :"active_admin.pagination.empty",
            :resource_name => active_admin_config.human_name
          )
          insert_tag(view_factory.blank_slate, empty_results_content)
        end
        
        def render_index
          renderer_class = find_index_renderer_class(config[:as])
          
          paginated_collection(collection, :entry_name => active_admin_config.human_name) do
            div :class => 'index_content' do
              insert_tag(renderer_class, config, collection)
            end
          end
        end

      end
    end
  end
end

