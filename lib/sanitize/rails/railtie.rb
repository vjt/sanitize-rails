module Sanitize::Rails

  class Railtie < ::Rails::Railtie
    initializer 'sanitize-rails.insert_into_action_view' do
      ::ActiveSupport.on_load :action_view do
        ::ActionView::Helpers::SanitizeHelper.instance_eval { include Sanitize::Rails::ActionView }
      end
    end

    initializer 'sanitize-rails.insert_into_active_record' do
      ::ActiveSupport.on_load :active_record do
        ::ActiveRecord::Base.extend Sanitize::Rails::ActiveRecord
      end
    end

    initializer 'sanitize-rails.insert_into_string' do
      ::String.instance_eval { include Sanitize::Rails::String }
    end
  end

end
