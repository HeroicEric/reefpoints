require 'builder'
require 'byebug'
require 'middleman-blog/tag_pages'

Dir['./lib/*'].each { |f| require f }

activate :blog do |blog|
  blog.permalink = ":year/:month/:day/:title.html"
  blog.sources = "posts/:year-:month-:day-:title.html"
  blog.paginate = true
  blog.tag_template = 'tag.html'
  blog.taglink = 'tags/:tag.html'
  blog.author_template = 'author.html'
  blog.authorlink = 'authors/:author.html'
end

module Middleman::Blog::BlogArticle
  def summary
    data['summary']
  end

  def tags
    article_tags = data['tags']

    if data['tags'].is_a? String
        article_tags = article_tags.split(',').map(&:strip)
    else
      article_tags = Array.wrap(article_tags)
    end
    Array.wrap(data['legacy_category']) + article_tags
  end
end

helpers do
  def tag_links(tags)
    tags.map do |tag|
      link_to tag_path(tag), class: 'post__meta--tag' do
        "#{tag_name(tag)} (#{tag_count(tag)})"
      end
    end.join(' ')
  end

  def tag_count(tag)
    blog.articles.select { |article| article.tags.include?(tag) }.size
  end

  def tag_name(tag)
    Middleman::Blog::TagPages.tag_name(tag)
  end

  def active_state_for(path)
    page_classes.split.first == (path) ? 'active' : nil
  end

  def active_state_for_sub(path)
    current_path[0..-6].split('/')[1] == (path.downcase.gsub(/[ ]/, '-')) ? 'active' : nil
  end

  def if_inside_category(path)
    (path.split(" ")[1]) != nil ? 'blog-subnav--nested' : nil
  end
end

set :markdown_engine, :redcarpet
set :markdown, :layout_engine => :erb, :fenced_code_blocks => true, :lax_html_blocks => true, :renderer => ::Highlighter::HighlightedHTML.new
activate :highlighter
activate :author_pages
activate :legacy_category
activate :asset_hash, ignore: /images/
ignore 'author.html.haml'
page 'sitemap.xml', layout: false
page 'atom.xml', layout: false

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'
set :haml, remove_whitespace: true
