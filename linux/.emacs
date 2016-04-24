;;脚本总文件夹位置。总是在.emacs文件最前面
(add-to-list 'load-path "~/.emacs.d/lisp")

;;运行speedbar可以打开文件管理器
;;查看当前mode的Key Bindings，用于检测绑定冲突
;;M-x describe-mode

;;取消24.3版本函数缺少提示：make-local-hook
(defalias 'make-local-hook
  (if (featurep 'xemacs)
      'make-local-hook
    'ignore))
(require 'util)
;;END make-local-hook setting

;;依赖24.4新版的with-eval-after-load宏定义，所以emacs24.3缺少下面的宏会无法启动。
(unless (fboundp 'with-eval-after-load)
  (defmacro with-eval-after-load (file &rest body)
    (declare (indent 1) (debug t))
    `(eval-after-load ,file '(progn ,@body))))

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
                     ;;python-mode
                     c-mode
                     c++-mode))
           (let ((mark-even-if-inactive transient-mark-mode))
             (indent-region (region-beginning) (region-end) nil))))))
;;----------------------    END    code setting    ---------------------

;; 设置缩进为space only
;;(setq indent-tabs-mode nil)
(setq default-tab-width 4)
(setq tab-width 4)
(setq tab-stop-list '(4 8 12 16 20 24 28 32 36 40
      44 48 52 56 60 64 68 72 76 80 84 88 92 96)) 
 

(setq default-major-mode 'text-mode)
(fset 'yes-or-no-p 'y-or-n-p)
(show-paren-mode t)
(display-time-mode 1)
(setq display-time t)

(set-fontset-font "fontset-default" 'unicode' ("Droid Sans Fallback" . "unicode-bmp"))
(require 'linum)
(setq linum-mode t)
(global-linum-mode 1)
;;不产生临时文件
(setq make-backup-files nil)
(auto-save-mode nil)
(setq auto-save-default nil)

(setq frame-title-format "黎醒聪@%f")
(setq default-fill-column 40)
(global-font-lock-mode t)


 
;;主题 
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")
;;https://github.com/oneKelvinSmith/monokai-emacs
;;(load-theme 'monokai t)

;;https://github.com/hbin/molokai-theme
(load-theme 'molokai t)
(setq molokai-theme-kit t)


;;设置默认的编译选项
(setq compile-command "g++ -g -o 1 ")
;;编译
(global-set-key (kbd "C-M-z") 'compile)

;;插入一行
(global-set-key (kbd "M-n") '(lambda () 
	(interactive) 
	(move-end-of-line 1) 
	(newline-and-indent)))
	

;;删除当前行
(global-set-key (kbd "M-i") 'kill-line)
;;定位到下一个,上一个编译错误
(global-set-key (kbd "M-q") 'next-error)
(global-set-key (kbd "M-a") 'previous-error)

;;隐藏菜单栏
(menu-bar-mode -1)
(tool-bar-mode -1)
;; 关闭启动画面
(setq inhibit-startup-message t)
;;到达某一行
(global-set-key (kbd "M-g") 'goto-line)
;;代码折叠:
(add-hook 'c-mode-hook 'hs-minor-mode)
(add-hook 'c++-mode-hook 'hs-minor-mode) 
;;关闭提示音
(setq ring-bell-function 'ignore)


;;启动清空*scratch*
(setq initial-scratch-message "")

;; 移除*messages*
(setq-default message-log-max nil)
(kill-buffer "*Messages*")
;; 打开文件后移除*Completions*
(add-hook 'minibuffer-exit-hook
      '(lambda ()
         (let ((buffer "*Completions*"))
           (and (get-buffer buffer)
                (kill-buffer buffer)))))
;; 当打开多个文件不显示*Buffer list*
(setq inhibit-startup-buffer-menu t)
;; 当打开多个文件只显示一个active window
;;(add-hook 'window-setup-hook 'delete-other-windows)


;;设置标记Set mark
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
;;反撤销C-x u

;;滚轮调节字体大小
;; For linux only, use <C-wheel-up> on windows
(global-set-key (kbd "<C-mouse-4>") 'text-scale-increase)
(global-set-key (kbd "<C-mouse-5>") 'text-scale-decrease)

;;快速注释整句按alt+l
(defun qiang-comment-dwim-line (&optional arg)
  "Replacement for the comment-dwim command."
  (interactive "*P")
  (comment-normalize-vars)
  (if (and (not (region-active-p)) (not (looking-at "[ \t]*$")))
      (comment-or-uncomment-region (line-beginning-position) (line-end-position))
    (comment-dwim arg)))
(global-set-key "\M-l" 'qiang-comment-dwim-line)

;;快速拷贝整一行,鼠标定位到行首即可拷贝
(defun qiang-copy-line (arg)
  "Copy lines (as many as prefix argument) in the kill ring"
  (interactive "p")
  (kill-ring-save (point)
                  (line-end-position))
                  ;; (line-beginning-position (+ 1 arg)))
  (message "%d line%s copied" arg (if (= 1 arg) "" "s")))
(global-set-key (kbd "M-m") 'qiang-copy-line)

;;下列3个defadvice不懂什么东西
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
 
;;打开当前文件夹的终端
;;如果是windows的话要改成("cmd" "/c" "start"),如果ubuntu根据实际修改
;;http://askubuntu.com/questions/183775/how-do-i-open-a-terminal
(defun popup-term ()
	(interactive)
	(apply 'start-process "terminal" nil popup-terminal-command)
	)
(setq popup-terminal-command '("gnome-terminal"))
(global-set-key (kbd "C-M-c") 'popup-term)

;;显示高亮当前行
(global-hl-line-mode 1)

;; 用eval-after-load避免不必要的elisp包的加载
;; http://emacser.com/eval-after-load.htm
(require 'ahei-misc)
(require 'eval-after-load)

;;VI模式
;;我在emaci.el文件中把when file exists的hook动作设为emaci-mode-off
(require 'emaci)
(require 'emaci-settings)
(global-set-key [(f11)] 'emaci-mode)

;;设置默认工作目录
;;(setq default-directory "F:/work/dev_cpp/temp/")
(setq default-directory "~/code/python/")


;;设置某个点来回跳动光标
;;新建标记点
(defun ska-point-to-register()
  "Store cursorposition _fast_ in a register.
Use ska-jump-to-register to jump back to the stored
position."
  (interactive)
  (setq zmacs-region-stays t)
  (point-to-register 8))
;;跳回标记点
(defun ska-jump-to-register()
  "Switches between current cursorposition and position
that was stored with ska-point-to-register."
  (interactive)
  (setq zmacs-region-stays t)
  (let ((tmp (point-marker)))
        (jump-to-register 8)
        ;;(set-register 8 tmp) ;;这里lxc注释掉了，每次都要多记录一组，反人类。
        ))
;;按键绑定
(global-set-key (kbd "M-2") 'ska-jump-to-register)
(global-set-key (kbd "M-1") 'ska-point-to-register)


;;启动ya函数补全
(add-to-list 'load-path  "~/.emacs.d/yasnippet")  
(require 'yasnippet)  
(yas-global-mode 1)  


;;启动auto-complete补全上文出现的字词插件
;;依赖popup.el
(add-to-list 'load-path  "~/.emacs.d/auto-complete")
(setq ac-dictionary-directories "~/.emacs.d/auto-complete/ac-dict")
(require 'auto-complete-config)
(setq ac-sources (append '(ac-source-yasnippet) ac-sources))
(ac-config-default)
;;设置是否自动运行补全，否则手动设置快捷键！
(setq ac-auto-start t)  
;;已修改AC补全快捷键，在auto-complete.el下列三个函数，最好修改ac-complete为M-v和\r两个同时使用
;;(define-key map "\M-c" 'ac-next)
;;(define-key map "\M-z" 'ac-previous)
;;(define-key map "\r" 'ac-complete)
;;全局
(global-auto-complete-mode t)
;;扩充buffer词库
(set-default 'ac-sources
             '(ac-source-imenu
               ac-source-dictionary
               ac-source-words-in-buffer
               ac-source-words-in-same-mode-buffers
               ac-source-words-in-all-buffer))
;;扩充AC-mode
(dolist (mode '(log-edit-mode org-mode text-mode haml-mode
                git-commit-mode
                sass-mode yaml-mode csv-mode espresso-mode haskell-mode
                html-mode nxml-mode sh-mode smarty-mode clojure-mode
                lisp-mode textile-mode markdown-mode tuareg-mode
                js3-mode css-mode less-css-mode sql-mode
                sql-interactive-mode
				;;MATLAB
				matlab-mode
                inferior-emacs-lisp-mode))
  				(add-to-list 'ac-modes mode))

;;只要里在你文档里有Time-stamp:的字样，启用time-stamp就会自动保存时间戳
(setq time-stamp-active t)
;;去掉time-stamp的警告
(setq time-stamp-warn-inactive t)
;;设置time-stamp的格式，我如下的格式所得的一个例子：
(setq time-stamp-format " %f %04y-%02m-%02d %02H:%02M:%02S ")
;;将修改时间戳添加到保存文件的动作里。
(add-hook 'write-file-hooks 'time-stamp)


;;光标自动改变
(require 'cursor-chg)
(require 'cursor-change)  
(cursor-change-mode 1)
;;按alt-r翻动鼠标，按alt-e遍历每行尾巴


;;设置窗格垂直还是水平(首先按c-x 2，且有多个窗口)
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
(global-set-key (kbd "M-3") 'toggle-window-split) 

;;添加书签功能，按next-error（M-q或者M-a）即可跳至这里
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
(global-set-key (kbd "M-h") 'add-code-review-note) 
;;根据语法缩进
(global-set-key (kbd "M-o") 'indent-according-to-mode) 

;;F10菜单栏
(global-set-key [(f10)] 'menu-bar-mode)

;; 不要闪烁光标, 烦不烦啊
(blink-cursor-mode -1)

;; Emacs找不到合适的模式时，缺省使用text-mode
(setq default-major-mode 'text-mode)

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

;; 光标靠近鼠标指针时，让鼠标指针自动隐藏。
(mouse-avoidance-mode 'none)
;; 页面平滑滚动，scroll-margin 5 靠近屏幕边沿3行时开始滚动，可以很好的看到上下文。
(setq scroll-margin 5 scroll-conservatively 10000)
;; 以下功能不清楚
(put 'narrow-to-region 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'dired-find-alternate-file 'disabled nil)


;;在M-x命令界面补全函数提示，依赖my-icomplete+.el和icomplete-settings.el
(require 'icomplete+)
(require 'icomplete-settings) ;; in this file, I modify the name 'my-icomplete' to 'icomplete'

;;操作符自动隔开模式（自动空格）依赖三个文件
;;https://github.com/davidshepherd7/electric-operator
(require 'subr-x)
(require 'names)
(require 'dash)
(require 'electric-operator)
(global-set-key [(f12)] 'electric-operator-mode)
;;若要指定某种mode开启electric-operator-mode,使用hook
(add-hook 'python-mode-hook #'electric-operator-mode)


;;自动插入配对括号 emacs 24+内置该功能
(electric-pair-mode 1)

;;python缩进4个空格
(add-hook 'python-mode-hook
      (lambda ()
        (setq indent-tabs-mode t)
        (setq tab-width 4)
        (setq python-indent 4)))
        

;;2016.1
;;K&R 风格
(setq c-default-style "k&r"
	c-basic-offset 4)
	
;;开启剪贴后删除当前set-mark内容
(delete-selection-mode)

;;WEB Mode插件 http://web-mode.org/
(require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.[agj]sp\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.js?\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.css?\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.xml?\\'" . web-mode))
;;web mode自动配对
(setq web-mode-enable-auto-closing t)
(setq web-mode-enable-auto-pairing t)
;;web-mode 元素对齐
(setq web-mode-markup-indent-offset 2)
(setq web-mode-css-indent-offset 2)
(setq web-mode-code-indent-offset 2)
;;web-mode 颜色
(setq web-mode-enable-css-colorization t)
(setq web-mode-enable-current-column-highlight t)
(set-face-attribute 'web-mode-html-tag-face nil :foreground "red3")
;;web-mode显示配对范围上下文
(setq web-mode-enable-current-element-highlight t)
(setq web-mode-enable-current-column-highlight t)

;;加入web-mode的Auto-complete插件，配合AC使用
(setq web-mode-ac-sources-alist
  '(("css" . (ac-source-css-property))
    ("html" . (ac-source-words-in-buffer ac-source-abbrev))))
    
;;行号左对齐，占位符2个，"-2d"其后紧跟一个空格隔开代码
(setq linum-format "%-2d ") 
;;默认启动字体大小，修改最后一个数字大小，100为原百分比。
;;改动该值会影响启动时候的窗口大小
;;(set-face-attribute 'default nil :height 100)

;;回车自动对齐
(electric-indent-mode 1)

;;选中代码后执行shitf-left或right
(global-set-key (kbd "S-<left>") 'indent-rigidly-left-to-tab-stop)
(global-set-key (kbd "S-<right>") 'indent-rigidly-right-to-tab-stop)


;;2016-4-18
;;默认为utf-8 no BOM 编码格式
(prefer-coding-system 'utf-8)

;;matlab语法模式 https://github.com/pronobis/matlab-mode
(require 'matlab)
;;绑定 matlab-mode 的Hook
(add-hook 'matlab-mode-hook
      (lambda ()
		;;MATLAB不支持utf-8，故显示中文需要GBK编码
		(set-buffer-file-coding-system 'gbk)
		(define-key matlab-mode-map (kbd "C-j") nil)
		(define-key matlab-mode-map (kbd "M-j") nil)
		(define-key matlab-mode-map (kbd "M-c") nil)
		))
		
;;在electric-operator.el中最后的namespace中加入matlab的模式
(add-hook 'matlab-mode-hook #'electric-operator-mode)




;;===========================================================================
;;=============以下设置到文件末尾，不需更改====================================
;;===========================================================================
;;Emacs自动生成的配置
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector
   ["#272822" "#F92672" "#A6E22E" "#E6DB74" "#66D9EF" "#FD5FF0" "#A1EFE4" "#F8F8F2"])
 '(compilation-message-face (quote default))
 '(custom-enabled-themes (quote (molokai)))
 '(custom-safe-themes
   (quote
	("c3c0a3702e1d6c0373a0f6a557788dfd49ec9e66e753fb24493579859c8e95ab" "43c28691d61b1232c5bed4517a168123245cc793faea84ffd1182b0fe38a6f4d" default)))
 '(display-time-mode t)
 '(fci-rule-color "#3E3D31")
 '(highlight-changes-colors (quote ("#FD5FF0" "#AE81FF")))
 '(highlight-tail-colors
   (quote
	(("#3E3D31" . 0)
	 ("#67930F" . 20)
	 ("#349B8D" . 30)
	 ("#21889B" . 50)
	 ("#968B26" . 60)
	 ("#A45E0A" . 70)
	 ("#A41F99" . 85)
	 ("#3E3D31" . 100))))
 '(magit-diff-use-overlays nil)
 '(pos-tip-background-color "#A6E22E")
 '(pos-tip-foreground-color "#272822")
 '(show-paren-mode t)
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
   (unspecified "#272822" "#3E3D31" "#A20C41" "#F92672" "#67930F" "#A6E22E" "#968B26" "#E6DB74" "#21889B" "#66D9EF" "#A41F99" "#FD5FF0" "#349B8D" "#A1EFE4" "#F8F8F2" "#F8F8F0")))
 
 ;;Emacs自动生成的配置
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
