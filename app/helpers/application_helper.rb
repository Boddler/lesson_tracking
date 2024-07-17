module ApplicationHelper
  def date_title(yyyymm)
    "#{yyyymm[0].to_s[0, 4]}, #{Date::MONTHNAMES[yyyymm[0].to_s[4, 2].to_i]}"
  end

  def text_title(text)
    text.sub!("Business Advantage", "Bus. Ad")
    text.sub!(" New", "")
    text.sub!("Medical Advantage", "Med. Ad")
    text.sub!("Target ", "")
    text.sub!("Shortcuts", "S/C")
    text.sub!("Pack ", "")
    text.sub!(" -2016 ED-", "")
    text.sub!("Level ", "")
    text
  end
end
