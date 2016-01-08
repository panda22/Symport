class QueryDetailsExportBuilder
  class << self

    def generate_query_details(details, project_name, page_header_text_1)
      
      logo_path = "#{Rails.root}/app/assets/images/symport-print-logo.jpg"
      normal_font_path = "#{Rails.root}/app/assets/fonts/OpenSans-Regular.ttf"
      bold_font_path = "#{Rails.root}/app/assets/fonts/OpenSans-Semibold.ttf"

      content_font_size = 11
      header_font_size = 14
      extra_space = 0
      extra_pos = 0
      if details[:sub_exc] != ""
        extra_space = extra_space + 16
      end
      if details[:name] && details[:name].length > 150
        extra_pos = 15
      end
      details[:secondary_lines].each do |line|
        extra_space = extra_space + 25
      end
      page_header_text_2 = "Visit www.symportresearch.com to learn more."      

      Prawn::Document.new(:page_layout => :portrait) do
        font_families.update("OpenSans" => {
          :normal => normal_font_path,
          :bold => bold_font_path
        })
        font "OpenSans"
        fill_color "58595b"
        text page_header_text_1, :size => content_font_size
        move_down 10
        text page_header_text_2, :size => content_font_size
        image logo_path, :position => :right, :vposition => :top, :width => 110, :height => 30
        if details[:name] != ""
          text_box details[:name], :at => [0, 675], :size => header_font_size, :style => :bold
        end
        move_down 40 + extra_pos
        fill_color "f2f2f2"
        fill_rectangle [-10,630 - extra_pos], 500, 38+extra_space
        fill_color "58595b"
        text details[:sub_line], :size => header_font_size, :style => :bold, :color => "638cd3"
        if details[:sub_exc] != ""
          move_down 5
          text details[:sub_exc], :size => content_font_size
        end
        details[:secondary_lines].each do |line|
          move_down 10
          text line, :size => header_font_size, :style => :bold
        end
        move_down 25
        text "Query Details", :size => header_font_size, :style => :bold
        move_down 20
        text "<b>Project name:</b> #{project_name}", :inline_format => true, :size => content_font_size 
        move_down 4
        text "<b>Form(s) Data shown In Query:</b> #{details[:form_string]}", :inline_format => true, :size => content_font_size
        move_down 20
        text "Query Parameters:", :size => content_font_size, :style => :bold
        move_down 4
        first = true
        details[:params].each do |param|
          if !first
            text details[:andor], :size => content_font_size, :style => :bold
            move_down 4
          else
            first = false
          end
          text param[:text], :size => content_font_size
          move_down 1
          text "(n = #{[param[:n], 0].max})", :size => content_font_size, :color => "638cd3"
          move_down 4
        end
        if first
          text "None", :size => content_font_size
        end
        number_pages "<page> of <total>", {:align => :right, :at => [bounds.right - 50, 0]}
      end.render
    end
  end
end