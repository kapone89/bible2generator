require "sqlite3"
require "nokogiri"

db = SQLite3::Database.new "biblia.db"

TRANSLATION_ID = 3 # 2 - IV wydanie, 3 - V wydanie

books = db.execute "SELECT id, number, shortTitle FROM book WHERE translation_id = #{TRANSLATION_ID} ORDER BY number ASC;"

# File.open("ksiegi.biblia", "a") do |f|
#   books.each do |book|
#     _id, number, shortTitle = book
#     f.puts "#{number} #{shortTitle}"
#   end
# end

File.open("bt5.biblia", "a") do |f|
  [books[0]].each do |book|
    book_id, book_number, _shortTitle = book

    chapters = db.execute "SELECT number, content, verseCount FROM chapter WHERE book_id = #{book_id} ORDER BY number ASC;"

    [chapters[0]].each do |chapter|
      chapter_number, content, verse_count = chapter

      html = Nokogiri::HTML(content)
      verses = html.css('.verse')

      raise "Invalid verses count" if verses.size != verse_count

      [verses[0]].each do |verse|
        verse_text = verse.text.strip
      end
    end
  end
end
#
# chapter_html = Nokogiri::HTML("")
#
# chapter_html.css('.verse')
#
# pp books
