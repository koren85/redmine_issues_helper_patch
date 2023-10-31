require 'redmine'

Redmine::Plugin.register :redmine_issues_helper_patch do
  name 'Redmine Issues Helper Patch plugin'
  author 'Chernyaev A.A.'
  description 'Добавляет поле итоговой даты в связанные и подзадачи'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  Rails.configuration.to_prepare do
    File.expand_path('../lib/issue_helper_patch', __FILE__)
    #require_dependency '/lib/issue_helper_patch'
    IssuesHelper.send(:include, IssuesHelperPatch)
  end

end


