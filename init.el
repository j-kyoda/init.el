;;; -*- mode: emacs-lisp; coding: utf-8 -*-
;;;

(require 'package)

; Add package-archives
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))

; Initialize
(package-initialize)

; atom
(unless (package-installed-p 'atom-dark-theme)
  (package-refresh-contents) (package-install 'atom-dark-theme))
(load-theme 'atom-dark t)


;;;
;;; 環境取得
;;;

(defvar run-unix
  (or (equal system-type 'gnu/linux)
      (equal system-type 'usg-unix-v)))
(defvar run-win
  (and (null run-unix)
       (or (equal system-type 'windows-nt)
           (equal system-type 'ms-dos))))
(defvar run-emacs24
  (and (equal emacs-major-version 24)
       (null (featurep 'xemacs))))
(defvar run-xemacs (featurep 'xemacs))


;;;
;;; 表示関連
;;;

;;; 起動時メッセージスキップ
(setq inhibit-startup-message t)

;;; 行番号・桁番号を表示する
(line-number-mode t)
(column-number-mode t)

;;; リージョンを可視化
(transient-mark-mode t)

;;; 対応する括弧を表示させる
(show-paren-mode t)

;;; ツールバーを消す
(when (or run-win run-xemacs)
  (tool-bar-mode -1)
  )

;;; スクロールバーを消す
(when (or run-win run-xemacs)
  (scroll-bar-mode -1)
  )

;;; ダイアログボックスを使わないようにする
(setq use-dialog-box nil)
(defalias 'message-box 'message)

;;; 全角、行末のスペース、タブを表示
(global-whitespace-mode 1)
(setq whitespace-style '(space-mark tab-mark face spaces tabs trailing))
(setq whitespace-display-mappings ())

(setq whitespace-space-regexp "\\(\u3000\\)")
(set-face-underline 'whitespace-space t)
(set-face-foreground 'whitespace-space "red")
(set-face-background 'whitespace-space 'nil)

;; whitespace-trailingを色つきアンダーラインで目立たせる
(set-face-underline 'whitespace-trailing t)
(set-face-foreground 'whitespace-trailing "cyan")
(set-face-background 'whitespace-trailing 'nil)

;; whitespace-tabを色つきアンダーラインで目立たせる
(set-face-underline  'whitespace-tab t)
(set-face-foreground 'whitespace-tab "cyan")
(set-face-background 'whitespace-tab 'nil)


;;;
;;; 記録関連
;;;

;;; ファイル内のカーソル位置を記憶する
(setq-default save-place t)
(require 'saveplace)

;;; ログの記録行数を増やす
(setq message-log-max 10000)

;;; 履歴をたくさん保存する
(setq history-length 1000)

;;; ミニバッファで入力を取り消しても履歴に残す
;;; 誤って取り消して入力が失われるのを防ぐため
(defadvice abort-recursive-edit (before minibuffer-save activate)
  (when (eq (selected-window) (active-minibuffer-window))
    (add-to-history minibuffer-history-variable (minibuffer-contents))))

;;;
;;; 動作環境
;;;

;;; 大きいファイルを開こうとしたときに警告を発生させる
;;; デフォルトは10MBなので25MBに拡張する
(setq large-file-warning-threshold (* 25 1024 1024))

;;; キーストロークをエコーエリアに早く表示する
(setq echo-keystrokes 0.1)

;;; GCを減らして軽くする（デフォルトの10倍）
(setq gc-cons-threshold (* 10 gc-cons-threshold))

;;; ミニバッファを再帰的に呼び出せるようにする
(setq enable-recursive-minibuffers t)


;;;
;;; キーバインド
;;;

;;; C-kで行削除
(setq kill-whole-line t)

;;; C-hを後退に割り当てる
(global-set-key "\C-h" 'delete-backward-char)


;;;
;;; モード設定
;;;

;;; c/c++
(add-hook 'c-mode-common-hook
          '(lambda ()
             (c-set-style "cc-mode")
             ;; インデントの変更
             (setq c-basic-offset 4)
             (setq c-indent-tabs-mode nil)
             (setq indent-tabs-mode nil)
             (setq tab-width 4)
             ))

;;; html-mode
(add-hook 'html-mode-hook
          '(lambda ()
             ;; インデントの変更
             (setq indent-tabs-mode nil)
             ))

;;; shell-script-mode
(add-hook 'sh-mode-hook
          '(lambda ()
             ;; インデントの変更
             (setq indent-tabs-mode nil)
             ))

;;; shell-mode
(add-hook 'shell-mode-hook
          '(lambda ()
             ;; インデントの変更
             (setq indent-tabs-mode nil)
             ))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; フレームサイズ最大化・通常化
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar my-fullscreen-p t "Check if fullscreen is on or off")

(defun my-non-fullscreen ()
  (interactive)
  (if (fboundp 'w32-send-sys-command)
      ;; WM_SYSCOMMAND restore #xf120
      (w32-send-sys-command 61728)
    (progn (set-frame-parameter nil 'width 82)
           (set-frame-parameter nil 'fullscreen 'fullheight))))

(defun my-fullscreen ()
  (interactive)
  (if (fboundp 'w32-send-sys-command)
      ;; WM_SYSCOMMAND maximaze #xf030
      (w32-send-sys-command 61488)
    (set-frame-parameter nil 'fullscreen 'fullboth)))

(defun my-toggle-fullscreen ()
  (interactive)
  (setq my-fullscreen-p (not my-fullscreen-p))
  (if my-fullscreen-p
      (my-non-fullscreen)
    (my-fullscreen)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 改善設定
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; ファイル名がかぶったときに、バッファ名をわかりやすくする(4.2)
(require 'uniquify)
;; filename<dir> 形式のバッファ名にする
(defvar uniquify-buffer-name-style 'post-forward-angle-brackets)
;; *で囲まれたバッファ名は対象外にする
(defvar uniquify-ignore-buffers-re "*[^*]+*")



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Windowsの設定
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(when run-win
  ;;; shell の設定
  ;;; Cygwin の bash を使う場合
  (defvar explicit-shell-file-name "")
  (setq explicit-shell-file-name "bash")
  (setq shell-file-name "sh")
  (setq shell-command-switch "-c")

  ;; ;;; WindowsNT に付属の CMD.EXE を使う場合。
  ;; (setq explicit-shell-file-name "CMD.EXE")
  ;; (setq shell-file-name "CMD.EXE")
  ;; (setq shell-command-switch "\\/c")

  ;;; shell coding-system の設定
  (add-hook 'shell-mode-hook
            (lambda ()
              (set-buffer-process-coding-system 'utf-8-dos 'utf-8-unix)))

  ;;; grepの設定(cygwin lv)
  (setq grep-command "lgrep -n -Ou8 ")
  (setq grep-program "lgrep")

  ;;; grep-findの設定
  (setq null-device "/dev/null")

  ; migemoの設定
  (unless (package-installed-p 'migemo)
    (package-refresh-contents) (package-install 'migemo))
  ;; migemo-dictのパスを指定
  (setq migemo-command "cmigemo")
  (setq migemo-options '("-q" "--emacs"))
  (setq migemo-directory "c:/tools/cmigemo-default-win64/dict/utf-8")
  (setq migemo-user-dictionary nil)
  (setq migemo-regex-dictionary nil)
  ;; キャッシュ機能を利用する
  (setq migemo-use-pattern-alist t)
  (setq migemo-use-frequent-pattern-alist t)
  (setq migemo-pattern-alist-length 1024)
  ;; 辞書の文字コードを指定．
  (setq migemo-coding-system 'utf-8-unix)
  (load-library "migemo")
  ;; 起動時に初期化も行う
  (migemo-init)


  ;;; シェルから現在のEmacsにアクセスする(4.6)
  (require 'server)
  (unless (server-running-p)
    (server-start))
  (defun iconify-emacs-when-server-is-done()
    (defvar server-clients "")
    (unless server-clients (iconify-frame)))
  ;; 編集が終了したらEmacsをアイコン化する（好みに応じて）
  (add-hook 'server-done-hook 'iconify-emacs-when-server-is-done)
  ;; C-x C-cに割り当てる（好みに応じて）
  (global-set-key (kbd "C-x C-c") 'server-edit)
  ;; M-x exitでEmacsを終了できるようにする
  (defalias 'exit 'save-buffers-kill-emacs)


  ;; ---------------------------------------------
  ;; 印刷設定
  ;;  Ghostscriptが必要
  ;;   http://sourceforge.net/projects/ghostscript/files/
  ;;  BDFが必要
  ;;   http://ftp.gnu.org/gnu/intlfonts/
  ;;
  ;;     M-x ps-print-buffer           バッファを白黒印刷
  ;;     M-x ps-print-buffer-with-face バッファをカラー印刷
  ;;     M-x ps-print-region           リージョンを白黒印刷
  ;;     M-x ps-print-region-with-face リージョンをカラー印刷
  ;; ---------------------------------------------

  (require 'cl)
  (defun listsubdir (basedir)
    (remove-if (lambda (x) (not (file-directory-p x)))
               (directory-files basedir t "^[^.]")))

  ;; フォントパスを指定
  ;;(setq bdf-directory-list
  ;;      (listsubdir "C:/cygwin/usr/local/share/emacs/fonts/"))

  ;; ghostscriptの実行コマンド場所を指定
  (defvar ps-print-color-p "")
  (defvar ps-lpr-command "")
  (defvar ps-lpr-switches "")
  (defvar ps-multibyte-buffer "")
  (defvar printer-name "")
  (defvar ps-printer-name "")
  (defvar ps-printer-name-option "")
  (defvar ps-print-header "")

  (setq ps-print-color-p t
        ;ps-lpr-command "gsview32.exe"
        ps-lpr-command "gswin64c.exe"
        ;ps-lpr-switches nil
        ps-lpr-switches '("-sDEVICE=mswinpr2" "-dNOPAUSE" "-dBATCH" "-dWINKANJI")
        ps-multibyte-buffer 'non-latin-printer
        printer-name nil
        ps-printer-name nil
        ps-printer-name-option nil
        ps-print-header nil          ; ヘッダの非表示
        )

  ;; ---------------------------------------------
  ;; 印刷設定
  ;; notepadを使って印刷
  ;; ---------------------------------------------
  (defvar print-region-function "")
  (setq print-region-function
        (lambda (start end
                       &optional lpr-prog
                       delete-text buf display
                       &rest rest)
          (let* ((procname (make-temp-name "w32-print-"))
                 (tempfile
                  (subst-char-in-string
                   ?/ ?\\
                   (expand-file-name procname temporary-file-directory)))
                 (coding-system-for-write 'sjis-dos))
            (write-region start end tempfile)
            (set-process-sentinel
             (start-process procname nil "notepad.exe" "/p" tempfile)
             (lambda (process event)
               (let ((tempfile
                      (expand-file-name (process-name process)
                                        temporary-file-directory)))
                 (when (file-exists-p tempfile)
                   (delete-file tempfile))))))))

  ) ;; when win

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; キーの設定
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; ヘルプ
;;; [f1]


;;; 検索を呼び出し
(global-set-key [f2] 'grep-find)


;;; 行番号に移動
(global-set-key [f3] 'goto-line)


;;; 置換を呼び出し
(global-set-key [f4] 'query-replace)


;;; 一行置きに行消しキーボードマクロ
;(fset 'delete-nextline "\C-n\C-k")
;(global-set-key [f5] 'delete-nextline)


;;; 最近開いたファイル一覧
;;  (global-set-key [f6] 'recentf-open-files)


;;; コンパイル
(global-set-key [f7] 'compile)


;;; スクリプト実行
(global-set-key [f8] 'executable-interpret)


;;; フレームサイズ最大化・通常化
(global-set-key [f9] 'my-toggle-fullscreen)


;;; メニューバー呼び出し
;;; [f10]


;;; 行番号付ける
;;(autoload 'setnu-mode "setnu" nil t)
;;(global-set-key [f11] 'setnu-mode)


;;;
;;; end of file

