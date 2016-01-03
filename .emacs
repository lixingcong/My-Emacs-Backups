;;脚本总文件夹位置。总是在.emacs文件最前面
(add-to-list 'load-path "~/.emacs.d/site-lisp")

;;2016.1
;;K&R 风格
(setq c-default-style "k&r"
	c-basic-offset 4)
		  
;;自动插入配对括号
;; auto close bracket insertion. New in emacs 24
(electric-pair-mode 1)

;;自动空格
;;https://github.com/davidshepherd7/electric-operator
;;依赖24.4新版的with-eval-after-load宏定义，所以emacs24.3缺少下面的宏会无法启动。
(unless (fboundp 'with-eval-after-load)
  (defmacro with-eval-after-load (file &rest body)
    (declare (indent 1) (debug t))
    `(eval-after-load ,file '(progn ,@body))))
(require 'subr-x)
(require 'names)
(require 'dash)
(require 'electric-operator)

(global-set-key [(f12)] 'electric-operator-mode)

;;区块代码左右平移
;;运行indent-rigidly或者C-x tab

;;2015.4
;;左侧栏的行号与代码间距
(set-fringe-mode '(1 . 1))

;;在M-x命令界面补全函数提示，依赖my-icomplete+.el和icomplete-settings.el
(require 'my-icomplete+)
(require 'icomplete-settings)
;;添加自定义的主题文件

(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")

;;载入color-theme.el主题库，不是主题。
;;(add-to-list 'load-path "~/.emacs.d/themes/color-theme")
;;(require 'color-theme)
;;(setq color-theme-is-global t)
;;载入主题颜色配置文件，不是主题
;;(load-file "~/.emacs.d/themes/color-theme/color-theme-almost-monokai.el")
;;(color-theme-almost-monokai)
;; 光标靠近鼠标指针时，让鼠标指针自动隐藏。
(mouse-avoidance-mode 'none)
;; 页面平滑滚动，scroll-margin 5 靠近屏幕边沿3行时开始滚动，可以很好的看到上下文。
(setq scroll-margin 5 scroll-conservatively 10000)
;; 以下功能不清楚
(put 'narrow-to-region 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'dired-find-alternate-file 'disabled nil)
;; 不保存连续的重复的kill
(setq kill-do-not-save-duplicates t)
;; 设置粘贴缓冲条目数量  
(setq kill-ring-max 200)
;; 显示列号
(setq column-number-mode t)
;; 高亮搜索  
(setq search-highlight t)  
(setq query-replace-highlight t)  
;; 先格式化再补全
(setq tab-always-indent 'complete)
;; Emacs找不到合适的模式时，缺省使用text-mode
(setq default-major-mode 'text-mode)
;; 在fringe上显示一个小箭头指示当前buffer的边界
;;(setq-default indicate-buffer-boundaries 'left)
;;为重名的buffer在前面加上其父目录的名字来让buffer的名字区分开来，而不是单纯的加一个没有太多意义的序号
;;(require 'uniquify)
(setq uniquify-buffer-name-style 'forward)
;; 不要闪烁光标, 烦不烦啊
(blink-cursor-mode -1)
;; 切换到当日的任务  
;;(global-set-key (kbd "<f12> g") 'planner-goto-today)  
;; 添加当前备忘录  ，你每次保存当前备忘录都会在/li/.notes文件末尾追加时间和备忘内容
;;(global-set-key (kbd "<f12> r") 'remember)  
;; 切换到日历  
;;(global-set-key (kbd "<f12> c") 'calendar)  




(global-set-key [(f10)] 'menu-bar-mode)
(setq gdb-many-windows t)
;;笔记功能，添加笔记后按next-error即可跳至这里
(defun add-code-review-note ()
  "Add note for current file and line number"
  (interactive)
  (let ((file-name (buffer-file-name))
		(file-line (line-number-at-pos)))
	(switch-to-buffer-other-window (get-buffer-create"NOTES"))
	(goto-char(point-min))
	(when (not (search-forward"-*- mode:compilation-shell-minor"
							  nil t))
	  (compilation-shell-minor-mode 1)
	  (insert"-*- mode:compilation-shell-minor -*-\n\n"))
	(goto-char(point-max))
	(if(/= (current-column) 0)
		(newline))
	(insert file-name":"(number-to-string file-line)": ")))
;;添加书签功能
;;(global-set-key (kbd "M-h") 'add-code-review-note) 
;;根据语法缩进
(global-set-key (kbd "M-o") 'indent-according-to-mode) 

(defun toggle-window-split ()
  (interactive)
  (if (= (count-windows) 2)
      (let* ((this-win-buffer (window-buffer))
             (next-win-buffer (window-buffer (next-window)))
             (this-win-edges (window-edges (selected-window)))
             (next-win-edges (window-edges (next-window)))
             (this-win-2nd (not (and (<= (car this-win-edges)
                                         (car next-win-edges))
                                     (<= (cadr this-win-edges)
                                         (cadr next-win-edges)))))
             (splitter
              (if (= (car this-win-edges)
                     (car (window-edges (next-window))))
                  'split-window-horizontally
                'split-window-vertically)))
        (delete-other-windows)
        (let ((first-win (selected-window)))
          (funcall splitter)
          (if this-win-2nd (other-window 1))
          (set-window-buffer (selected-window) this-win-buffer)
          (set-window-buffer (next-window) next-win-buffer)
          (select-window first-win)
          (if this-win-2nd (other-window 1))))))
;;设置窗格垂直还是水平(首先按c-x 2，且有多个窗口)
(global-set-key (kbd "M-3") 'toggle-window-split) 
(require 'ahei-misc)
(require 'eval-after-load)

;;这个插件可以鼠标滚轮调整子窗口的宽度和高度
(require 'doremi)
(require 'doremi-cmd)
;;快捷键 调整子窗口 高度 宽度
(global-set-key (kbd "C--") 'doremi-window-height+) 
(global-set-key (kbd "C-=") 'doremi-window-width+)
 
;;取消24版本函数缺少提示：make-local-hook
(defalias 'make-local-hook
  (if (featurep 'xemacs)
      'make-local-hook
    'ignore))
(require 'util)

(require 'cursor-chg)
;;光标自动改变，需要cursor-chg.el,cursor-change.el
(require 'cursor-change)  
(cursor-change-mode 1)

;;是否开启vi模式？
(require 'emaci)
(require 'emaci-settings)
(global-set-key [(f11)] 'emaci-mode)
;;鼠标变形
(require 'cursor-change)
;;(require 'ascii)
;;按alt-l注释当前行，快速屏蔽，按alt-;给当前行尾加注释
;;按alt-v选择自动补全，tab只能选择第一个
;;按alt-r翻动鼠标，按alt-e遍历每行尾巴
;;运行speedbar可以打开文件管理器
;;时间戳设置(time-stamp)，设定文档上次保存的信息iiii
;;只要里在你得文档里有Time-stamp:的设置，就会自动保存时间戳
;;启用time-stamp
(setq time-stamp-active t)
;;去掉time-stamp的警告？
(setq time-stamp-warn-inactive t)
;;设置time-stamp的格式，我如下的格式所得的一个例子：
(setq time-stamp-format " %f %04y年%02m月%02d日 %02H:%02M:%02S ")
;;将修改时间戳添加到保存文件的动作里。
(add-hook 'write-file-hooks 'time-stamp)
;;启动ya函数补全
(add-to-list 'load-path  "~/.emacs.d/yasnippet")  
(require 'yasnippet)  
(yas/global-mode 1)  
;;启动auto-complete补全上文出现的字词插件
(add-to-list 'load-path  "~/.emacs.d/auto-complete")
(setq ac-dictionary-directories "~/.emacs.d/auto-complete/ac-dict")
(require 'auto-complete-config)
(setq ac-sources (append '(ac-source-yasnippet) ac-sources))
(ac-config-default)
;;设置是否自动运行补全，否则手动设置快捷键！
(setq ac-auto-start t)  
;;手动设置快捷键补全
;; (define-key ac-mode-map  "\M-v" 'auto-complete)  
;;延迟
(setq ac-quick-help-delay 0.5)  
;;tab继续补全
;;(ac-set-trigger-key "TAB")  
(global-set-key (kbd "M-v")'ac-complete)  
;;(define-key ac-mode-map  [(control tab)] 'auto-complete)
(defun ska-point-to-register()
  "Store cursorposition _fast_ in a register.
Use ska-jump-to-register to jump back to the stored
position."
  (interactive)
  (setq zmacs-region-stays t)
  (point-to-register 8))
(defun ska-jump-to-register()
  "Switches between current cursorposition and position
that was stored with ska-point-to-register."
  (interactive)
  (setq zmacs-region-stays t)
  (let ((tmp (point-marker)))
        (jump-to-register 8)
        (set-register 8 tmp)))
;;设置某个点来回跳动光标
(global-set-key (kbd "M-2") 'ska-jump-to-register)
(global-set-key (kbd "M-1") 'ska-point-to-register)
;;(setq default-directory "F:/work/dev_cpp/temp/")
(setq default-directory "~/code/python/")
;;选中一块代码，按 Ctrl-Alt-\ 对这块代码进行格式化。
;;调试模式下 f3移除断点 f4设置断点 f5.gud-go  f6.gud-finish  f7.gud-next f8.gud-step  
;;gud-next 下一行(跳过函数) gud-step 步入(进入函数) gud-finish 跳出函数
;;可以用gdb下M-x运行gud-tooltip-mode开启后将鼠标指针停留在变量名上显示
;;可以用gdb下M-x运行gdb-many-windows打开多窗口显示
;;阅读模式,依赖ahei-misc.el。和eval-after-load。util.el。emaci.el
;;进入emaci-mode后, 和vi类似, hjkl上下左右以字符单位移动光标
;;f, b前进和后退一个单词
;;I回到行首并且退出emaci-mode, A回到行尾并且退出emaci-mode
;;u向上滚半屏, SPC向下滚半屏, w向上滚一屏, d向下滚一屏
;;<和>回到buffer头和buffer尾 g也是回到buffer头, 
;;B执行eval-buffer
;;1最大化当前window, 2把当前buffer垂直分成两半，3把当前buffer水平非常两半，q退出emaci-mode
;;(require 'emaci-settings)
;; 一些基本的小函数
;;(require 'ahei-misc)
;; 利用`eval-after-load'加快启动速度的库
;; 用eval-after-load避免不必要的elisp包的加载
;; http://emacser.com/eval-after-load.htm
(require 'eval-after-load)

;;(require 'ascii)
;;快捷键打开ascii，需要ascii.el
;;(global-set-key (kbd "M-6") 'ascii-on)
;;显示高亮当前行
;;(global-hl-line-mode 1)
;;变换3个窗口位置,仅在C-x 3中使用
(defun switch-windows-buffer ()
  (interactive)
  (let ((this-buffer (window-buffer)))
    (switch-to-buffer (window-buffer (next-window (selected-window))))
    (switch-to-buffer-other-window this-buffer)
    (other-window 1)
    )
)
;;(global-set-key (kbd "M-6") 'switch-windows-buffer)
;;打开当前文件夹的终端
(defun popup-term ()
  (interactive)
  (apply 'start-process "terminal" nil popup-terminal-command)
  )
(setq popup-terminal-command '("gnome-terminal"))
(global-set-key (kbd "C-M-c") 'popup-term)
;;如果是windows的话要改成("cmd" "/c" "start")
;;如果ubuntu根据实际修改
;;http://askubuntu.com/questions/183775/how-do-i-open-a-terminal

(defadvice kill-line (before check-position activate)
  (if (member major-mode
              '(emacs-lisp-mode scheme-mode lisp-mode
                                c-mode c++-mode objc-mode js-mode
                                latex-mode plain-tex-mode))
      (if (and (eolp) (not (bolp)))
          (progn (forward-char 1)
                 (just-one-space 0)
                 (backward-char 1)))))
 
(defadvice kill-ring-save (before slick-copy activate compile)
  "When called interactively with no active region, copy a single line instead."
  (interactive (if mark-active (list (region-beginning) (region-end))
                 (message "Copied line")
                 (list (line-beginning-position)
                       (line-beginning-position 2)))))
 
(defadvice kill-region (before slick-cut activate compile)
  "When called interactively with no active region, kill a single line instead."
  (interactive
   (if mark-active (list (region-beginning) (region-end))
     (list (line-beginning-position)
           (line-beginning-position 2)))))
 
;; Copy line from point to the end, exclude the line break
(defun qiang-copy-line (arg)
  "Copy lines (as many as prefix argument) in the kill ring"
  (interactive "p")
  (kill-ring-save (point)
                  (line-end-position))
                  ;; (line-beginning-position (+ 1 arg)))
  (message "%d line%s copied" arg (if (= 1 arg) "" "s")))
;;快速拷贝整一行,鼠标定位到行首即可拷贝
(global-set-key (kbd "M-m") 'qiang-copy-line)
(defun qiang-comment-dwim-line (&optional arg)
  "Replacement for the comment-dwim command.
If no region is selected and current line is not blank and we are not at the end of the line,
then comment current line.
Replaces default behaviour of comment-dwim, when it inserts comment at the end of the line."
  (interactive "*P")
  (comment-normalize-vars)
  (if (and (not (region-active-p)) (not (looking-at "[ \t]*$")))
      (comment-or-uncomment-region (line-beginning-position) (line-end-position))
    (comment-dwim arg)))
;;快速注释整句按alt+l
(global-set-key "\M-l" 'qiang-comment-dwim-line)
;;放大字体: Ctrl-x Ctrl-+ 或 Ctrl-x Ctrl-=
;;缩小字体: Ctrl-x Ctrl–
;;重置字体: Ctrl-x Ctrl-0
;; For Windows
(global-set-key (kbd "<C-wheel-up>") 'text-scale-increase)
(global-set-key (kbd "<C-wheel-down>") 'text-scale-decrease)
;;反撤销C-x u
;;显示行号
(global-linum-mode)
;;设置标记c-m
(global-set-key (kbd "C-o") 'set-mark-command)
;;设置补全功能
;;(global-set-key (kbd "M-m") 'dabbrev-expand)
;;括号跳转
(global-set-key (kbd "C-7") 'forward-sexp)
(global-set-key (kbd "C-8") 'backward-sexp)
;;字符左一个右一个
(global-set-key (kbd "C-k") 'backward-char)
(global-set-key (kbd "C-j") 'forward-char)
;;上一行下一行
(global-set-key (kbd "M-k") 'previous-line)
(global-set-key (kbd "M-j") 'next-line)
;;上页下页
(global-set-key (kbd "M-7") 'scroll-up)
(global-set-key (kbd "M-8") 'scroll-down)
;;撤销
(global-set-key (kbd "C-z") 'undo)
;;按下C-y后，按此键，切换粘贴的内容
;;隐藏菜单栏
(menu-bar-mode -1)
;; 关闭启动画面
(setq inhibit-startup-message t)
;;到达某一行
(global-set-key (kbd "M-g") 'goto-line)
;;代码折叠:
(add-hook 'c-mode-hook 'hs-minor-mode)
(add-hook 'c++-mode-hook 'hs-minor-mode) 
;;关闭提示音
(setq ring-bell-function 'ignore)

(global-set-key (kbd "C-M-x") 'gdb)
;;设置默认的编译选项
(setq compile-command "g++ -g -o 1 ")
;;(setq compile-command "javac ")
;;(setq compile-command "c51.bat ")
;;插入一行
(global-set-key (kbd "M-n") '(lambda () 
(interactive) 
(move-end-of-line 1) 
(newline-and-indent)))
;;编译
(global-set-key (kbd "C-M-z") 'compile)
;;错误信息显示在回显区
;;(condition-case err(progn(require 'xxx) )(error(message "Can't load xxx-mode %s" (cdr err))))
;;不产生临时文件
(setq-default make-backup-files nil)
;;删除当前行
(global-set-key (kbd "M-i") 'kill-line)
;;定位到下一个,上一个编译错误
(global-set-key (kbd "M-q") 'next-error)
(global-set-key (kbd "M-a") 'previous-error)
;;添加自动补全函数原型功能


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector
   ["black" "#d55e00" "#009e73" "#f8ec59" "#0072b2" "#cc79a7" "#56b4e9" "white"])
 '(ansi-term-color-vector
   [unspecified "#000000" "#d54e53" "#afd75f" "#e7c547" "#5f87d7" "#af87d7" "#5f87d7" "#dadada"])
 '(blink-cursor-mode nil)
 '(column-number-mode t)
 '(compilation-message-face (quote default))
 '(custom-enabled-themes (quote (evenhold)))
 '(custom-safe-themes
   (quote
	("523d5a027e2f378ad80f9b368db450f4a5fa4a159ae11d5b66ccd78b3f5f807d" "1faffcddc50d5dc7d334f2817dd6f159ef1820be3aad303eb7f74006531afdff" "4aafea32abe07a9658d20aadcae066e9c7a53f8e3dfbd18d8fa0b26c24f9082c" "a72ca8173e7552bd46cad2d8fae36c524247e824193be24c187b67d674f51c39" "ac9aa2b6dfa2c7a248d37d02917d0e37f383bc8d1c6278e34248f322cc35bf2a" "6289eea37cab3a69bf8ab01dd5ab854e02e8e59a75051b0288176ab920b88a32" "d9046dcd38624dbe0eb84605e77d165e24fdfca3a40c3b13f504728bab0bf99d" "143a83d976f25871dfa645134cd2bb7efeb9e911d2bffacfccc7ee4dcd723f99" "5f3e4547a22fe320ac6b26cb3f6f7b2c6bef6ec85d0fb7c9e0a7e663c06a8698" default)))
 '(display-time-mode t)
 '(fci-rule-character-color "#1c1c1c")
 '(fci-rule-color "#49483E")
 '(highlight-changes-colors ("#FD5FF0" "#AE81FF"))
 '(highlight-tail-colors
   (quote
	(("#49483E" . 0)
	 ("#67930F" . 20)
	 ("#349B8D" . 30)
	 ("#21889B" . 50)
	 ("#968B26" . 60)
	 ("#A45E0A" . 70)
	 ("#A41F99" . 85)
	 ("#49483E" . 100))))
 '(magit-diff-use-overlays nil)
 '(show-paren-mode t)
 '(tool-bar-mode nil)
 '(vc-annotate-background nil)
 '(vc-annotate-color-map
   (quote
	((20 . "#F92672")
	 (40 . "#CF4F1F")
	 (60 . "#C26C0F")
	 (80 . "#E6DB74")
	 (100 . "#AB8C00")
	 (120 . "#A18F00")
	 (140 . "#989200")
	 (160 . "#8E9500")
	 (180 . "#A6E22E")
	 (200 . "#729A1E")
	 (220 . "#609C3C")
	 (240 . "#4E9D5B")
	 (260 . "#3C9F79")
	 (280 . "#A1EFE4")
	 (300 . "#299BA6")
	 (320 . "#2896B5")
	 (340 . "#2790C3")
	 (360 . "#66D9EF"))))
 '(vc-annotate-very-old-color nil)
 '(weechat-color-list
   (unspecified "#272822" "#49483E" "#A20C41" "#F92672" "#67930F" "#A6E22E" "#968B26" "#E6DB74" "#21889B" "#66D9EF" "#A41F99" "#FD5FF0" "#349B8D" "#A1EFE4" "#F8F8F2" "#F8F8F0")))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(setq frame-title-format "黎醒聪@%b")
(setq default-fill-column 80)
(global-font-lock-mode t)
;;调试设置
(global-set-key [(f3)] 'gud-remove)
(global-set-key [(f4)] 'gud-break)
(global-set-key [(f5)] 'gud-go)
(global-set-key [(f6)] 'gud-finish)
(global-set-key [(f7)] 'gud-next)
(global-set-key [(f8)] 'gud-step)

(setq gdb-many-windows t)
(setq default-major-mode 'text-mode)
(fset 'yes-or-no-p 'y-or-n-p)
(show-paren-mode t)
(display-time-mode 1)
(setq display-time-24hr-format t)
(setq display-time-day-and-date t)
(setq display-time-interval 10)
(set-fontset-font "fontset-default" 'gb18030' ("Droid Sans Fallback" . "unicode-bmp"))
(require 'linum)
(setq linum-mode t)
(global-linum-mode 1)
(setq make-backup-files nil)
(auto-save-mode nil)
(setq auto-save-default nil)

;; 设置智能缩进
;;(setq indent-tabs-mode nil)
(setq default-tab-width 4)
(setq tab-width 4)
(setq tab-stop-list '(4 8 12 16 20 24 28 32 36 40
      44 48 52 56 60 64 68 72 76 80 84 88 92 96)) 


;;======================    code setting        =========================
(dolist (command '(yank yank-pop))
  (eval
   `(defadvice ,command (after indent-region activate)
      (and (not current-prefix-arg)
           (member major-mode
                   '(emacs-lisp-mode
                     lisp-mode
                     clojure-mode
                     php-mode
                     scheme-mode
                     haskell-mode
                     ruby-mode
                     rspec-mode
                     python-mode
                     c-mode
                     c++-mode))
           (let ((mark-even-if-inactive transient-mark-mode))
             (indent-region (region-beginning) (region-end) nil))))))
;;----------------------    END    code setting    ---------------------
