require 'redmine'
module InlineTicket
  mattr_accessor :fetched_tickets
  mattr_accessor :hours
  
  def self.render_ticket(issue)
    res = "<p>"
    res += "<del>" if issue.closed?
    res += "<a href='/issues/#{issue.id}' style='color: #000;'><b>#{issue.subject}</b></a>"
    res += "</del>" if issue.closed?
    res += " ##{issue.id} "
    if issue.description && !issue.description.blank?
      res += " -- " + issue.description[0..200] + (issue.description.length > 200 ? "..." : "") + " "
    end
    if issue.estimated_hours.to_f > 0
      InlineTicket.hours ||= 0
      InlineTicket.hours += issue.estimated_hours.to_f
      res += "<span style='font-size: 0.8em; padding-left: 5px;'>#{issue.estimated_hours.to_f} hrs</span> "
    end
    tags = issue.issue_tags.map(&:name).join(',') rescue []
    if !tags.empty?
      res += "<span style='font-size: 0.8em;'>(#{tags})</span>"
    end
    res += "</p>"
    res
  end

  Redmine::WikiFormatting::Macros.register do
    desc "prefetch a list of tickets to be rendered somewhere in this page"
    macro :prefetch_tickets do |stuff, ids|
      includes = defined?(IssueTag) ? [:issue_tags, :status] : [:status]
      InlineTicket.fetched_tickets = Issue.find(:all, :conditions => {:id => ids}, :include => includes)
      InlineTicket.hours = 0.0
      ''
    end
  end
  
  Redmine::WikiFormatting::Macros.register do
    desc "render the ticket"
    macro :ticket do |stuff, args|
      id, str = args
      id = id.to_i
      ticket = (InlineTicket.fetched_tickets || []).detect{|t| t.id == id }
      if !ticket
        includes = defined?(IssueTag) ? [:issue_tags] : []
        ticket ||= Issue.find(:first, :conditions => {:id => id}, :include => includes)
      end
      InlineTicket.render_ticket(ticket)
    end
  end
  Redmine::WikiFormatting::Macros.register do
    desc "total number of hours for all those tickets"
    macro :ticket_hours do
      hrs = InlineTicket.hours ||= 0.0
      InlineTicket.hours = 0.0
      "<p>#{hrs} hours total</p>"
    end
  end
end