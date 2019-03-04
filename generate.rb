require "sqlite3"
require "nokogiri"

db = SQLite3::Database.new "biblia.db"

TRANSLATION_ID = 3 # 2 - IV wydanie, 3 - V wydanie
ENCODING = 'Windows-1250'
DEUTERO = '( 17, 18, 20, 21, 27, 28, 32 )'

books_order = "number IN #{DEUTERO} ASC, number ASC"
books = db.execute "SELECT id, number, shortTitle FROM book WHERE translation_id = #{TRANSLATION_ID} ORDER BY #{books_order};"

File.open("BT_wyd#{TRANSLATION_ID + 2}_ksiegi.biblia", "a") do |f|
  books.each_with_index do |book, book_idx|
    _id, number, shortTitle = book
    f.puts "#{book_idx + 1} #{shortTitle}".encode(ENCODING)
  end
end

File.open("BT_wyd#{TRANSLATION_ID + 2}_tekst.biblia", "a") do |f|
  books.each_with_index do |book, book_idx|
    book_id, book_number, shortTitle = book

    chapters = db.execute "SELECT number, content FROM chapter WHERE book_id = #{book_id} ORDER BY number ASC;"

    chapters.each do |chapter|
      chapter_number, content = chapter

      content.gsub!('<br>', ' ')

      html = Nokogiri::HTML(content)
      verses = html.css('.verse')

      verses.each_with_index do |verse, i|
        verse_number = i + 1
        verse_text = verse.text.strip
        f.puts "#{ (book_idx + 1).to_s.rjust(3, "0") }#{ chapter_number.to_s.rjust(3, "0") }#{ verse_number.to_s.rjust(3, "0") } #{verse_text}".encode(ENCODING)
      end
    end
  end
end
