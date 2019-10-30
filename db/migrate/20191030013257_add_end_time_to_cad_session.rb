class AddEndTimeToCadSession < ActiveRecord::Migration[6.0]
  def change
    add_column :cad_sessions, :begin_operation, :string
    add_column :cad_sessions, :end_operation, :string
    Cad::CadSession.where(operation: 'Begin').update_all(begin_operation: 'Begin')
    Cad::CadSession.where(begin_operation: 'Begin').find_each do |s|
      end_session = Cad::CadSession.find_by(session: s.session, operation: 'End')
      if end_session.present?
        s.update(updated_at: end_session.created_at, end_operation: 'End')
        end_session.destroy
      end
    end
  end
end
