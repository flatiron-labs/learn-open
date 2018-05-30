module LearnOpen
  class SystemAdapter
    def self.open_editor(editor, path:)
      system("#{editor} .")
    end

    def self.open_login_shell(shell)
      exec("#{shell} -l")
    end
  end
end
