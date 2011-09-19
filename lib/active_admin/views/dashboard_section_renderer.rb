module ActiveAdmin
  module Views
    class DashboardSection < ActiveAdmin::Views::Panel

      def build(section)
        @section = section
        super(title, :icon => @section.icon)
        instance_eval &@section.block
      end

      protected

      def title
        I18n.t(@section.name,
          :scope => [ :active_admin, :dashboards, @section.namespace ],
          :default => @section.name.to_s.titleize
        )
      end

    end
  end
end
