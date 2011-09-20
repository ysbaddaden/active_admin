require 'active_admin/helpers/optional_display'

module ActiveAdmin

  class Resource
    module ActionItems

      # Add the default action items to a resource when it's
      # initialized
      def initialize(*args)
        super
        add_default_action_items
      end

      # @return [Array] The set of action items for this resource
      def action_items
        @action_items ||= []
      end

      # Add a new action item to a resource
      #
      # @param [Hash] options valid keys include:
      #                 :only:  A single or array of controller actions to display
      #                         this action item on.
      #                 :except: A single or array of controller actions not to
      #                          display this action item on.
      def add_action_item(options = {}, &block)
        self.action_items << ActiveAdmin::ActionItem.new(options, &block)
      end

      # Returns a set of action items to display for a specific controller action
      #
      # @param [String, Symbol] action the action to retrieve action items for
      #
      # @return [Array] Array of ActionItems for the controller actions
      def action_items_for(action)
        action_items.select{|item| item.display_on?(action) }
      end

      # Clears all the existing action items for this resource
      def clear_action_items!
        @action_items = []
      end

      private

      # Adds the default action items to each resource
      def add_default_action_items
        # New Link on all actions except :new and :show
        add_action_item :except => [:new, :show] do
          if controller.action_methods.include?('new')
            txt = I18n.t('activeadmin.resources.#{active_admin_config.resource_name}.links.new_model',
              :default => :"active_admin.new_model", :model => active_admin_config.human_name)
            link_to(txt, new_resource_path)
          end
        end

        # Edit link on show
        add_action_item :only => :show do
          if controller.action_methods.include?('edit')
            txt = I18n.t('activeadmin.resources.#{active_admin_config.resource_name}.links.edit_model',
              :default => :"active_admin.edit_model", :model => active_admin_config.human_name)
            link_to(txt, edit_resource_path(resource))
          end
        end

        # Destroy link on show
        add_action_item :only => :show do
          if controller.action_methods.include?("destroy")
            txt = I18n.t('activeadmin.resources.#{active_admin_config.resource_name}.links.delete_model',
              :default => :"active_admin.delete_model", :model => active_admin_config.human_name)
            confirm_txt = I18n.t('activeadmin.resources.#{active_admin_config.resource_name}.links.delete_confirmation',
              :default => :"active_admin.delete_confirmation", :model => active_admin_config.human_name)
            link_to(txt, resource_path(resource), :method => :delete, :confirm => confirm_txt)
          end
        end
      end

    end
  end

  # Model class to store the data for ActionItems
  class ActionItem
    include ActiveAdmin::OptionalDisplay

    attr_accessor :block

    def initialize(options = {}, &block)
      @options, @block = options, block
      normalize_display_options!
    end
  end

end
