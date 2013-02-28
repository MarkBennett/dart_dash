require "sqlite3"
require 'nokogiri'
require 'pry'

class DartIndexer

  # Process the contents of Dart.docset/Contents/Resources/Documents and
  # produce a sqlite3 index in Dart.docset/Contents/Resources/docSet.dsidx
  def index
    index = DashIndex.new

    paths = [
      "dart_async/Future.html"
    ]
    paths.each do |path|
      index.add_tokens(DartPageParser.new("Dart.docset/Contents/Resources/Documents/", path).tokens)
    end
  end
end

class DartPageParser
  def initialize(doc_root, page_path)
    @doc_root = doc_root
    @page_path = page_path
  end

  # Scan the page returning tokens matching the parser
  def tokens
    tokens = []

    # Add static methods
    page = Nokogiri::HTML(open(@doc_root + @page_path))
    tokens += page_title_token(page)
    tokens += static_methods_tokens(page)
    tokens += constructor_tokens(page)
  end

  def page_title_token(page)
    page_title = page.css(".content h2 strong").text

    [
      {
        :name => page_title,
        :type => "Class",
        :path => @page_path
      }
    ]
  end

  def static_methods_tokens(page)
    tokens = []
    static_methods_section = page.xpath('//h3[contains(text(), "Static Methods")]')
    static_methods_section.each do |section|
      section.parent.css(".method").each do |method|
        name = method.children[0].attributes["id"].value
        path = @page_path + "#" + name
        tokens << { :name => name, :type => "Method", :path => path }
      end
    end

    tokens
  end

  def constructor_tokens(page)
    tokens = []
    constructors_sections = page.xpath('//h3[contains(text(), "Constructors")]')
    constructors_sections.each do |section|
      section.parent.css(".method").each do |method|
        name = method.children[0].attributes["id"].value
        path = @page_path + "#" + name
        tokens << { :name => name, :type => "Constructor", :path => path }
      end
    end

    tokens
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
