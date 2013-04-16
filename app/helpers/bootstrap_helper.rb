module BootstrapHelper
  def tab_nav_item(tab_text, tab_link, options={})
     outer_classes = options[:class]
     inner_classes = options[:inner_class]
     content_tag(:li, class: "#{outer_classes if outer_classes}") do
       content_tag(:a, href: tab_link, class: "#{inner_classes if inner_classes}", data: {toggle: "tab"}) do
         tab_text
       end
     end
  end
end
