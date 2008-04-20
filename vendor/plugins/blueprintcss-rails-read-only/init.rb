require 'blueprint_css/stylesheets'

ActionView::Helpers::AssetTagHelper.send(:include, BlueprintCss::Stylesheets)
