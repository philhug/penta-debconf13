module VideoHelper

  def status_table(row, column, status = nil)
    xml = Builder::XmlMarkup.new
    status = Video_file_status.select() unless status
    xml.table do
      status.each do |st|
        if row and column
          name = "#{row.class.table.table_name}[#{column}]"
          id = "#{name}_#{st.id}"
        end
        xml.tr do
          xml.td(:class => "recording_status_#{st.file_status_code}") do
            if row and column
              xml.input({:type=>:radio,:value=>st.id, :id => id, :name => name})
              xml.label(:for => id) do
                xml.text st.file_status_code
              end
            else
              xml.text st.file_status_code
            end
          end
          if row and column
            xml.td do
              xml.label(:for => id) do
                xml.text(st.file_status_desc)
              end
            end
          else
              xml.td(st.file_status_desc)
          end
        end
      end
    end
    xml
  end

end
