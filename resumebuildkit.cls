\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{resumebuildkit}[2026/01/07 v2.0]
\LoadClass{article}

% --- Required Packages ---
\RequirePackage[margin=0.5in]{geometry}
\RequirePackage{enumitem}
\RequirePackage[hidelinks]{hyperref}
\RequirePackage{xparse}
\RequirePackage{fontspec}

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
    
    \newcommand{\dates}[2]{%
      % Append each role/date line without expanding font commands inside \edef
      \g@addto@macro\roleslist{%
        \noindent \rescurrrole \hfill {\bodyfont ##1 -- ##2} \par
      }%
    }
    
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
