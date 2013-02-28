require "sqlite3"

class DartIndexer

  # Process the contents of Dart.docset/Contents/Resources/Documents and
  # produce a sqlite3 index in Dart.docset/Contents/Resources/docSet.dsidx
  def index
    index = DashIndex.new
    index.add_token("Future", "Class", "dart_async/Future.html")
    index.add_token("Stream<T>", "Class", "dart_async/Stream.html")
  end
end

class DashIndex
  def initialize
    @db = SQLite3::Database.new "Dart.docset/Contents/Resources/docSet.dsidx"
    @db.execute("CREATE TABLE searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT)")
  end

  def add_token(name, type, path)
    @db.execute "INSERT INTO searchIndex(name, type, path) VALUES ( ?, ?, ?)", [name, type, path]
  end
end
