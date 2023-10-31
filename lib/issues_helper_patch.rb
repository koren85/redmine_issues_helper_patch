# frozen_string_literal: true

module IssuesHelperPatch
  def self.included(base)
    base.class_eval do
      # def render_issue_subject(issue, opts={})
      #   # здесь переопределяется метод
      # end

      def render_descendants_tree(issue)
        manage_relations = User.current.allowed_to?(:manage_subtasks, issue.project)
        s = +'<table class="list issues odd-even">'
        issue_list(
          issue.descendants.visible.
            preload(:status, :priority, :tracker,
                    :assigned_to).sort_by(&:lft)) do |child, level|
          css = +"issue issue-#{child.id} hascontextmenu #{child.css_classes}"
          css << " idnt idnt-#{level}" if level > 0
          buttons =
            if manage_relations
              link_to(l(:label_delete_link_to_subtask),
                      issue_path(
                        {:id => child.id, :issue => {:parent_issue_id => ''},
                         :back_url => issue_path(issue.id), :no_flash => '1'}),
                      :method => :put,
                      :data => {:confirm => l(:text_are_you_sure)},
                      :title => l(:label_delete_link_to_subtask),
                      :class => 'icon-only icon-link-break'
              )
            else
              "".html_safe
            end
          buttons << link_to_context_menu

          s <<
            content_tag(
              'tr',
              content_tag('td', check_box_tag("ids[]", child.id, false, :id => nil),
                          :class => 'checkbox') +
                content_tag('td',
                            link_to_issue(
                              child,
                              :project => (issue.project_id != child.project_id)),
                            :class => 'subject') +
                content_tag('td', h(child.status), :class => 'status') +

                content_tag('td', link_to_user(child.assigned_to), :class => 'assigned_to') +
                content_tag('td', format_date(child.start_date), :class => 'start_date') +
                content_tag('td', format_date(child.due_date), :class => 'due_date') +
                content_tag('td',format_date( child.custom_field_value(81).to_datetime ), :class => 'due_date') +

                content_tag('td',
                            (if child.disabled_core_fields.include?('done_ratio')
                               ''
                             else
                               progress_bar(child.done_ratio)
                             end),
                            :class=> 'done_ratio') +

                #chernyaev
                content_tag('td', buttons, :class => 'buttons'),
              :class => css)
        end
        s << '</table>'
        s.html_safe
      end

      def render_issue_relations(issue, relations)
        manage_relations = User.current.allowed_to?(:manage_issue_relations, issue.project)
        s = ''.html_safe
        relations.each do |relation|
          other_issue = relation.other_issue(issue)
          css = "issue hascontextmenu #{other_issue.css_classes}"
          buttons =
            if manage_relations
              link_to(
                l(:label_relation_delete),
                relation_path(relation),
                :remote => true,
                :method => :delete,
                :data => {:confirm => l(:text_are_you_sure)},
                :title => l(:label_relation_delete),
                :class => 'icon-only icon-link-break'
              )
            else
              "".html_safe
            end
          buttons << link_to_context_menu
          #chernyaev
          vlad_id=[34,35,37,54,72]
          if vlad_id.include? other_issue.project_id
            z1=content_tag('td',( other_issue.custom_field_value(63) ), :class => 'subject')
          else
            z1=''
          end
          #chernyaev
          result_day_value = other_issue.custom_field_value(81)
          formatted_date = result_day_value && result_day_value.respond_to?(:to_datetime) ? format_date(result_day_value.to_datetime) : ''
          s <<
            content_tag(
              'tr',
              content_tag('td',
                          check_box_tag(
                            "ids[]", other_issue.id,
                            false, :id => nil),
                          :class => 'checkbox') +
                content_tag('td',
                            relation.to_s(@issue) {|other|
                              link_to_issue(
                                other,
                                :project => Setting.cross_project_issue_relations?)
                            }.html_safe,
                            :class => 'subject') +
                content_tag('td', other_issue.status, :class => 'status') +
                #chernyaev
                content_tag('td',
                            (if User.current.allowed_to?(:view_time_entries, issue.project)
                               other_issue.total_estimated_hours
                             else
                               ''
                             end),
                            :class => 'estimated_hours') +
                #chernyaev
                content_tag('td', link_to_user(other_issue.assigned_to), :class => 'assigned_to') +
                content_tag('td', format_date(other_issue.start_date), :class => 'start_date') +
                content_tag('td', format_date(other_issue.due_date), :class => 'due_date') +
                content_tag('td',formatted_date,  :class => 'due_date') +
                #chernyaev
                z1+
                content_tag('td',
                            (if other_issue.disabled_core_fields.include?('done_ratio')
                               ''
                             else
                               progress_bar(other_issue.done_ratio)
                             end),
                            :class=> 'done_ratio') +
                content_tag('td', buttons, :class => 'buttons'),
              :id => "relation-#{relation.id}",
              :class => css)
        end
        content_tag('table', s, :class => 'list issues odd-even')
      end

    end
  end
end