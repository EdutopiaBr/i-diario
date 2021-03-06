module Navigation
  class MenuRender < Navigation::Render::Base
    def render(menus)
      render_menus(menus)
    end

    protected

    def render_menus(menus, html_options = {})
      content_tag :ul, html_options do
        html = menus.map do |menu|
          render_menu(menu)
        end.join(" ")

        raw html
      end
    end

    def render_menu(menu)
      has_submenus = menu[:subnodes].any?

      can_show = if menu[:visible]
                   true
                 elsif has_submenus
                   has_visible_submenus?(menu[:subnodes])
                 else
                   can_show?(menu[:type])
                 end

      if can_show
        content_tag :li, :class => menu[:css_class].join(" ") do
          li = []
          menu_path = path_method menu[:path]

          li << link_to(menu_path) do
            link = []
            link_content = I18n.t(menu[:type], :scope => :navigation)

            if menu[:icon]
              link << content_tag(:i, "", :class => "fa fa-lg fa-fw #{menu[:icon]}")
            end

            link << content_tag(:span, link_content, :class => "menu-item-parent")

            raw link.join(" ")
          end

          if has_submenus
            options = {}

            options[:style] = "display: block;" if menu[:css_class].include?(:open)

            li << render_menus(menu[:subnodes], options)
          end

          raw li.join(" ")
        end
      else
        ""
      end
    end

    def has_visible_submenus?(subnodes)
      subnodes.any? do |node|
        can_show?(node[:type])
      end
    end

    def can_show?(feature)
      policy(feature).index?
    end

    def policy(feature)
      klass = feature.singularize.camelcase.constantize

      begin
        Pundit::PolicyFinder.new(klass).policy!.new(current_user, klass)
      rescue
        ApplicationPolicy.new(current_user, klass)
      end
    end
  end
end
