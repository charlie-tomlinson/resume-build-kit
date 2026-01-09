\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{resumebuildkit}[2026/01/07 v2.0]
\LoadClass{article}
\pagestyle{empty}
\pagenumbering{gobble}

% --- Required Packages ---
\RequirePackage[margin=0.5in]{geometry}
\RequirePackage{enumitem}
\RequirePackage[hidelinks]{hyperref}
\RequirePackage{xparse}
\RequirePackage{fontspec}
\RequirePackage{graphicx}

% --- Font & Style ---
\setmainfont{Arial Narrow}
\newcommand{\namefont}{\bfseries\fontsize{20}{11}\selectfont}
\newcommand{\sectionfont}{\bfseries\fontsize{11}{11}\selectfont}
\newcommand{\bodyfont}{\mdseries\fontsize{10.5}{11}\selectfont}
\newcommand{\cvsep}{\enspace•\enspace}
\hyphenpenalty=10000 \exhyphenpenalty=10000 \pretolerance=10000
\raggedright % no hyphenation or stretched lines
\newif\if@contactcollecting
\newif\if@contactfirst
\newcommand{\contact}[1]{%
  \if@contactcollecting
    \if@contactfirst\@contactfirstfalse\else\g@addto@macro\rescontact{\unskip\cvsep}\fi
    \g@addto@macro\rescontact{#1}%
  \fi
}

% --- Header ---
\NewDocumentCommand{\header}{+m}{
  \begingroup
    \newcommand{\name}[1]{\def\resname{##1}}
    \def\rescontact{}
    \newcommand{\contactinfo}[1]{%
      \gdef\rescontact{}%
      \@contactcollectingtrue
      \@contactfirsttrue
      ##1%
      \@contactcollectingfalse
    }
    #1
    \noindent{\namefont \resname}\par
    \vspace{2pt}\hrule height 1pt \vspace{4pt}
    \noindent{\bodyfont \rescontact}\par
  \endgroup
}

% --- Sections ---
\renewcommand{\section}[1]{%
  \vspace{8pt}%
  \noindent{\sectionfont\MakeUppercase{#1}}\par
  \vspace{2pt}\noindent\hrule height 0.5pt \vspace{4pt}%
}

% --- Entry Engine ---
\newcommand{\roleslist}{} 
\newlength{\skilllabelwidth}
\ExplSyntaxOn
\cs_new_protected:Npn \rbkhighlightformat #1
  { % normalize highlight text (trim + ensure trailing period)
    \tl_set:Nn \l_tmpa_tl { #1 }
    \tl_trim_spaces:N \l_tmpa_tl
    \tl_if_empty:NF \l_tmpa_tl
      {
        \regex_replace_once:nnN { [.!?:;]*\s*\z } { } \l_tmpa_tl
        \tl_put_right:Nn \l_tmpa_tl { . }
        \tl_use:N \l_tmpa_tl
      }
  }
\ExplSyntaxOff
\newcommand{\rbkhighlight}[1]{\item \rbkhighlightformat{#1}}

\NewDocumentCommand{\entry}{+m}{
  \begingroup
    \gdef\roleslist{} % Clear for new entry
    \def\restitle{} \def\resloc{} \def\rescurrrole{} \def\reshighlights{}
    
    \newcommand{\school}[2]{\def\restitle{{\bodyfont\bfseries ##1}\if\relax\detokenize{##2}\relax\else, {\bodyfont ##2}\fi}}
    \newcommand{\company}[2]{\def\restitle{{\bodyfont\bfseries ##1}\if\relax\detokenize{##2}\relax\else\ {\bodyfont\bfseries -- ##2}\fi}}
    
    \newcommand{\location}[2]{\def\resloc{{##1}\if\relax\detokenize{##2}\relax\else, ##2\fi}}
    
    \newcommand{\role}[2]{\def\rescurrrole{{\bodyfont\itshape ##1\if\relax\detokenize{##2}\relax\else\ -- ##2\fi}}}
    \newcommand{\degree}[2]{\def\rescurrrole{{\bodyfont\itshape ##1\if\relax\detokenize{##2}\relax\else, ##2\fi}}}

    \newcommand{\rbkappendroleline}[3]{%
      \begingroup
        \toks@{##1}%
        \def\rbk@datestring{}%
        \def\rbk@start{##2}%
        \def\rbk@end{##3}%
        \if\relax\detokenize{\rbk@start}\relax
          \if\relax\detokenize{\rbk@end}\relax
          \else
            \edef\rbk@datestring{\rbk@end}%
          \fi
        \else
          \if\relax\detokenize{\rbk@end}\relax
            \edef\rbk@datestring{\rbk@start}%
          \else
            \edef\rbk@datestring{\rbk@start\space -- \space \rbk@end}%
          \fi
        \fi
        \protected@xdef\roleslist{%
          \roleslist
          \noindent \the\toks@
          \if\relax\detokenize{\rbk@datestring}\relax
            \noexpand\par
          \else
            \noexpand\hfill {\noexpand\bodyfont \rbk@datestring} \noexpand\par
          \fi
        }%
      \endgroup
    }

    \newcommand{\dates}[2]{%
      \rbkappendroleline{\rescurrrole}{##1}{##2}%
    }

    \ExplSyntaxOn
    \tl_clear_new:N \l_rbk_role_title_tl
    \tl_clear_new:N \l_rbk_role_suffix_tl
    \tl_clear_new:N \l_rbk_role_start_tl
    \tl_clear_new:N \l_rbk_role_end_tl
    \tl_clear_new:N \l_rbk_role_line_tl
    \keys_define:nn { rbk/roleblock }
      {
        title .tl_set:N       = \l_rbk_role_title_tl,
        title .required:,
        titlesuffix .tl_set:N = \l_rbk_role_suffix_tl,
        titlesuffix .default: = ,
        startdate .tl_set:N   = \l_rbk_role_start_tl,
        startdate .default:   = ,
        enddate .tl_set:N     = \l_rbk_role_end_tl,
        enddate .default:     = ,
      }
    \cs_set:Npn \rbk_role_titlesuffix_text:
      { \tl_if_blank:NTF \l_rbk_role_suffix_tl { } { \space -- \tl_use:N \l_rbk_role_suffix_tl } }
    \cs_set_protected:Npn \rbk_roleblock:n #1
      {
        \keys_set:nn { rbk/roleblock } { #1 }
        \tl_set:Nx \l_rbk_role_line_tl
          {
            {\noexpand\bodyfont\noexpand\itshape
              \tl_use:N \l_rbk_role_title_tl
              \rbk_role_titlesuffix_text:
            }
          }
        \rbkappendroleline{\l_rbk_role_line_tl}{\tl_use:N \l_rbk_role_start_tl}{\tl_use:N \l_rbk_role_end_tl}
      }
    \ExplSyntaxOff

    \newcommand{\roleblock}[1]{\rbk_roleblock:n{##1}}
    
    \newcommand{\highlights}[1]{\g@addto@macro\reshighlights{\vspace{2pt}{\bodyfont\begin{itemize}[leftmargin=0.5em, labelwidth=0.4em, labelsep=0.3em, labelindent=0pt, itemsep=0pt, topsep=0pt, partopsep=0pt, parsep=0pt, label=\normalsize•]%
        \let\highlight\rbkhighlight
        ##1\end{itemize}}}}

    #1 % Execute data

    \noindent \restitle \hfill {\bodyfont \resloc} \par
    \roleslist 
    \reshighlights
    \vspace{4pt}
  \endgroup
}

\NewDocumentCommand{\skills}{+m}{
  \begingroup
    \newcommand{\skillitem}[2]{%
      {\bodyfont
        \settowidth{\skilllabelwidth}{\bfseries ##1: }%
        \noindent\hangindent=\skilllabelwidth\hangafter=1
        {\bfseries ##1: }##2\par}%
      \vspace{0pt}%
    }
    #1
  \endgroup
}

% --- Signature Block ---
\newcommand{\signatureblock}[1][0.3]{% optional scale factor, default = 0.35
  {\bodyfont
    Sincerely,\par
    \vspace{4pt}%
    \begingroup
      \edef\sigscale{#1}%
      \IfFileExists{assets/signature.png}{%
        \includegraphics[scale=\sigscale]{assets/signature.png}%
      }{%
        \IfFileExists{../assets/signature.png}{%
          \includegraphics[scale=\sigscale]{../assets/signature.png}%
        }{%
          \IfFileExists{signature.png}{%
            \includegraphics[scale=\sigscale]{signature.png}%
          }{[signature image missing]}%
        }%
      }%
    \endgroup
    \par
    \vspace{2pt}%
    Charles Tomlinson\par
  }%
}

% --- Letter Header Block ---
% Usage: \letterheader{street}{city/state/zip}{attn name}{subject}{salutation name}
\newcommand{\letterheader}[5]{%
  {\bodyfont
    \noindent\today\par
    \noindent #1\par
    \noindent #2\par
    \vspace{6pt}%
    \noindent{\bfseries Attn:} #3\par
    \noindent{\bfseries Re:} #4\par
    \vspace{6pt}%
    \noindent #5,\par
    \vspace{6pt}%
  }%
}
