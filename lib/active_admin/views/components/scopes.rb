module ActiveAdmin
  module Views

    # Renders a collection of ActiveAdmin::Scope objects as a
    # simple list with a seperator
    class Scopes < ActiveAdmin::Component
      builder_method :scopes_renderer

      def build(scopes)
        scopes.each do |scope|
          build_scope(scope)
        end
      end

      protected

      def build_scope(scope)
        span :class => classes_for_scope(scope) do
          i18n_scope = if scoping_class.respond_to?(:model_name)
            scoping_class.model_name.i18n_key
          else
            scoping_class.name.underscore
          end

          scope_name = I18n.t("activeadmin.resources.#{i18n_scope}.scopes.#{scope.id}",
            :default => [ "activeadmin.scopes.#{scope.id}".to_sym, scope.name ]
          )

          if current_scope?(scope)
            em(scope_name)
          else
            a(scope_name, :href => url_for(params.merge(:scope => scope.id, :page => 1)))
          end
          text_node(" ")
          scope_count(scope)
          text_node(" ")
        end
      end

      def classes_for_scope(scope)
        classes = ["scope", scope.id]
        classes << "selected" if current_scope?(scope)
        classes.join(" ")
      end

      def current_scope?(scope)
        if params[:scope]
          params[:scope] == scope.id
        else
          active_admin_config.default_scope == scope
        end
      end

      def scope_count(scope)
        span :class => 'count' do
          "(" + get_scope_count(scope).to_s + ")"
        end
      end

      include ActiveAdmin::ScopeChain

      # Return the count for the scope passed in.
      def get_scope_count(scope)
        scope_chain(scope, scoping_class).count
      end

      def scoping_class
        assigns["before_scope_collection"] || active_admin_config.resource
      end

    end
  end
end
