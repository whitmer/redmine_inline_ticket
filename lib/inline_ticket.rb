require 'redmine'
module InlineTicket
  mattr_accessor :ticket_ids
  
  def self.render_ticket(issue)
    res = "##{issue.id} <a href='/issues/#{issue.id}'><b>#{issue.subject}</b></a> "
    if issue.description && !issue.description.blank?
      res += " -- " + issue.description[0..100] + " "
    end
    if issue.estimated_hours.to_f > 0
      res += "<span style='font-size: 0.8em;'>#{issue.estimated_hours.to_f} hrs</span> "
    end
    tags = issue.issue_tags.map(&:name).join(',') rescue []
    if !tags.empty?
      res += "<span style='font-size: 0.8em;'>(#{tags})</span>"
    end
    res
  end

  Redmine::WikiFormatting::Macros.register do
    desc "stash the ticket id to be rendered in next call to render_tickets... second argument is a string description for reference"
    macro :ticket do |id, str|
      InlineTicket.ticket_ids ||= []
      InlineTicket.ticket_ids << id
      ""
    end
  end
  Redmine::WikiFormatting::Macros.register do
    desc "render the list of tickets that are currently stashed, and then the total number of hours for all those tickets"
    macro :render_tickets do
      hrs = 0
      res = ""
      
      includes = defined?(IssueTag) ? [:issue_tags] : []
      issues = Issue.find(:all, :conditions => {:id => InlineTicket.ticket_ids}, :include => includes)
      issues.each do |issue|
        res += InlineTicket.render_ticket(issue) + "<br/><br/>"
        hrs += issue.estimated_hours.to_f
      end
      InlineTicket.ticket_ids = []
      res += "#{hrs} hours total"
      res
    end
  end
end