;;
;; ~/.config/emacs/init.el
;;
;; https://protesilaos.com/codelog/2024-11-28-basic-emacs-configuration/

;; BASIC =======================================================================

;; Disable some package warnings.
(add-to-list 'display-buffer-alist
             '("\\`\\*\\(Warnings\\|Compile-Log\\)\\*\\'"
               (display-buffer-no-window)
               (allow-no-window . t)))

;; Disable some GUI elements.
(menu-bar-mode -1)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(blink-cursor-mode -1)

;; FONTS =======================================================================

(let ((mono-spaced-font "JetBrainsMono Nerd Font")
      (proportionately-spaced-font "JetBrainsMono Nerd Font"))
  (set-face-attribute 'default nil :family mono-spaced-font :height 90)
  (set-face-attribute 'fixed-pitch nil :family mono-spaced-font :height 0.9)
  (set-face-attribute 'variable-pitch nil :family proportionately-spaced-font :height 0.9))


;; PLUGIN MANAGER ==============================================================

;; Change the user directories for emacs folders.
(defvar user-emacs-share-directory "/home/batpacg/.local/share/emacs")

;; Install package manager.
(defvar elpaca-installer-version 0.12)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-share-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-sources-directory (expand-file-name "sources/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca-activate)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-sources-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (let ((load-source-file-function nil)) (load "./elpaca-autoloads"))))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; Install use-package support.
(elpaca elpaca-use-package
  ;; Enable use-package :ensure support for Elpaca.
  (elpaca-use-package-mode))

;;Turns off elpaca-use-package-mode current declaration
;;Note this will cause evaluate the declaration immediately. It is not deferred.
;;Useful for configuring built-in emacs features.
(use-package emacs :ensure nil :config (setq ring-bell-function #'ignore))

;; COLORSCHEME =================================================================

(use-package gruvbox-theme
  :ensure t
  :config
  (load-theme 'gruvbox :no-confirm-loading))

;; VI EMULATION ================================================================

(use-package evil
  :ensure t
  :demand t
  :init
  (setq evil-want-C-u-scroll t)
  (setq evil-split-window-below t)
  (setq evil-vsplit-window-right t)
  :config
  (evil-mode 1)
  (evil-define-key 'normal 'global
    (kbd "C-p") #'execute-extended-command
    (kbd "C-j") #'term
    (kbd "SPC s") #'save-buffer
    (kbd "SPC d") #'kill-buffer
    (kbd "SPC e") #'dired-jump
    (kbd "SPC f") #'consult-fd
    (kbd "SPC j") #'consult-buffer)
)

;; MINIBUFFER ==================================================================

(use-package vertico
  :ensure t
  :hook (elpaca-after-init . vertico-mode))

(use-package marginalia
  :ensure t
  :hook (elpaca-after-init . marginalia-mode))

(use-package orderless
  :ensure t
  :config
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides nil))

(use-package consult
  :ensure t
  :bind (("C-x b" . consult-buffer)
         ("M-y" . consult-yank-pop)
         ("C-s" . consult-line)))

;; PROJECT MANAGEMENT ==========================================================

(use-package project
  :ensure t
  :config
  (setq default-directory "~/")
  )

;; AUTOCOMPLETE ================================================================

(use-package corfu
  :ensure t
  :hook (elpaca-after-init . global-corfu-mode)
  :bind (:map corfu-map ("<tab>" . corfu-complete))
  :config
  (setq tab-always-indent 'complete)
  (setq corfu-preview-current nil)
  (setq corfu-min-width 20)

  (setq corfu-popupinfo-delay '(1.25 . 0.5))
  (corfu-popupinfo-mode 1) ; shows documentation after `corfu-popupinfo-delay'
  )

;; FILE MANAGEMENT =============================================================

(use-package dired
  :ensure nil
  :commands (dired)
  :hook
  ((dired-mode . dired-hide-details-mode)
   (dired-mode . hl-line-mode))
  :config
  (setq dired-recursive-copies 'always)
  (setq dired-recursive-deletes 'always)
  (setq delete-by-moving-to-trash t)
  (setq dired-dwim-target t))

;; ICONS =======================================================================

(use-package nerd-icons
  :ensure t)

(use-package nerd-icons-completion
  :ensure t
  :after marginalia
  :config
  (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))

(use-package nerd-icons-corfu
  :ensure t
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

(use-package nerd-icons-dired
  :ensure t
  :hook
  (dired-mode . nerd-icons-dired-mode))
