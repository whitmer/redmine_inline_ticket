require 'redmine'

Redmine::Plugin.register :redmine_inline_ticket do
  name 'Redmine Inline Ticket plugin'
  author 'Brian Whitmer'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://www.instructure.com'
  author_url 'http://www.instructure.com'
  InlineTicket
end
