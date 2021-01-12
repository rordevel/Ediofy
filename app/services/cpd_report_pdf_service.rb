require 'csv'
require 'erb'

class CpdReportPdfService
  include ActionView::Helpers
  include WickedPdf::WickedPdfHelper
  include WickedPdf::WickedPdfHelper::Assets

  attr_accessor  :user, :cpd_times, :learning, :teaching, :from, :to, :include_comment

  def initialize(user, cpd_times, learning, teaching, from, to, include_comment)
    self.user = user
    self.cpd_times = cpd_times
    self.learning = learning
    self.teaching = teaching
    self.from = from
    self.to = to
    self.include_comment = include_comment
  end

  def render_pdf
    binding.local_variable_set(:user, user)
    binding.local_variable_set(:cpd_times, cpd_times)
    binding.local_variable_set(:learning, learning)
    binding.local_variable_set(:teaching, teaching)
    binding.local_variable_set(:from, from)
    binding.local_variable_set(:to, to)
    binding.local_variable_set(:include_comment, include_comment)

    template = File.read(Rails.root.join('app/views/pdf/cpd_report.html.erb'))
    string = ERB.new(template).result(binding)
    WickedPdf.new.pdf_from_string(string)
  end
end
