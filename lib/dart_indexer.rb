require "sqlite3"

class DartIndexer

  # Process the contents of Dart.docset/Contents/Resources/Documents and
  # produce a sqlite3 index in Dart.docset/Contents/Resources/docSet.dsidx
  def index
    index = DashIndex.new

    paths = [
      "dart_async/Future.html"
    ]
    paths.each do |path|
      index.add_tokens(DartPageParser.new(path).tokens)
    end
  end
end

class DartPageParser
  def intialize(page_path)
    @page_path = page_path
  end

  # Scan the page returning tokens matching the parser
  def tokens
    [
      { :name => "Future", :type => "Class", :path => "dart_async/Future.html"},
      { :name => "Stream<T>", :type => "Class", :path => "dart_async/Stream.html"}
    ]
  end
end

class DashIndex
  DB_PATH = "Dart.docset/Contents/Resources/docSet.dsidx"
  def initialize
    FileUtils.rm(DB_PATH)
    @db = SQLite3::Database.new DB_PATH
    @db.execute("CREATE TABLE searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT)")
  end

  def add_tokens(tokens)
    tokens.each do |token|
      @db.execute "INSERT INTO searchIndex(name, type, path) VALUES ( ?, ?, ?)",
        [token[:name], token[:type], token[:path]]
    end
  end
end
