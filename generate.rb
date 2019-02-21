require "sqlite3"
require "nokogiri"

db = SQLite3::Database.new "biblia.db"

TRANSLATION_ID = 3 # 2 - IV wydanie, 3 - V wydanie

books = db.execute "SELECT id, number, shortTitle FROM book WHERE translation_id = #{TRANSLATION_ID} ORDER BY number ASC;"

File.open("ksiegi.biblia", "a") do |f|
  books.each do |book|
    _id, number, shortTitle = book
    f.puts "#{number} #{shortTitle}"
  end
end

File.open("bt5.biblia", "a") do |f|
  books.each do |book|
    book_id, book_number, shortTitle = book

    chapters = db.execute "SELECT number, content FROM chapter WHERE book_id = #{book_id} ORDER BY number ASC;"

    chapters.each do |chapter|
      chapter_number, content = chapter

      html = Nokogiri::HTML(content)
      verses = html.css('.verse')

      verses.each_with_index do |verse, i|
        verse_number = i + 1
        verse_text = verse.text.strip
        f.puts "#{ book_number.to_s.rjust(3, "0") }#{ chapter_number.to_s.rjust(3, "0") }#{ verse_number.to_s.rjust(3, "0") } #{verse_text}"
      end
    end
  end
end
