class DatabaseClearingController < ApplicationController
    def clear
        ActiveRecord::Base.connection.execute("DELETE FROM Infos")
        #flash message
        flash[:error] = 'Database Cleared!'
        redirect_to '/uploads/new'
    end
end
