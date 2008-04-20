module BlueprintCss
  module Stylesheets
    def self.included(base)
      base.class_eval do
        alias_method_chain :stylesheet_link_tag, :blueprint
      end
    end

    def stylesheet_link_tag_with_blueprint(*sources)
      returning [] do |stylesheets|
        if sources.delete(:blueprint)
          if RAILS_ENV == 'producton'
            stylesheets << stylesheet_link_tag_without_blueprint('blueprint/compressed/screen',  :media => 'screen, projection')
            stylesheets << stylesheet_link_tag_without_blueprint('blueprint/compressed/print',   :media => 'print')
          else
            stylesheets << stylesheet_link_tag_without_blueprint('blueprint/screen',  :media => 'screen, projection')
            stylesheets << stylesheet_link_tag_without_blueprint('blueprint/print',   :media => 'print')
          end
          stylesheets << '<!--[if IE]>'
          stylesheets << stylesheet_link_tag_without_blueprint('blueprint/lib/ie',  :media => 'screen, projection')
          stylesheets << '<![endif]-->'
        end
        stylesheets << stylesheet_link_tag_without_blueprint(*sources)
      end.join("\n")
    end
  end
end