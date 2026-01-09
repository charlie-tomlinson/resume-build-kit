\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{resumepro}[2026/01/09 v41.0]
\LoadClass{article}

% =============================================================================
% CORE DEPENDENCIES
% =============================================================================
\RequirePackage[margin=0.5in]{geometry}
\RequirePackage{xkeyval}
\RequirePackage[inline]{enumitem} % Required for horizontal lists like contact/details
\RequirePackage{fontspec}
\RequirePackage{environ}
\RequirePackage[hidelinks]{hyperref}

% =============================================================================
% LENGTHS AND SPACING
% =============================================================================
\newcommand{\vHeaderRuleTop}{2pt}
\newcommand{\vHeaderRuleBot}{4pt}
\newcommand{\vSectionTop}{7pt}
\newcommand{\vSectionRuleTop}{2pt}
\newcommand{\vSectionRuleBot}{4pt}
\newcommand{\vRoleToHighlight}{3pt}
\newcommand{\vHighlightSep}{1pt}
\newcommand{\vEntryEnd}{4pt}

% Bullet Specific Spacing
\newcommand{\vHighlightLabelSep}{0.6em} 
\newcommand{\vHighlightIndent}{1.2em}   

% =============================================================================
% TYPOGRAPHY (THE THREE LEVELS)
% =============================================================================
\setmainfont{Arial Narrow}

\newcommand{\sizeOne}{\fontsize{20pt}{11pt}\selectfont}
\newcommand{\sizeTwo}{\fontsize{11pt}{11pt}\selectfont}
\newcommand{\sizeThree}{\fontsize{10.5pt}{11pt}\selectfont}

% =============================================================================
% COMPONENT STYLES
% =============================================================================
\newcommand{\styleName}{\sizeOne\bfseries}
\newcommand{\styleSection}{\sizeTwo\bfseries}
\newcommand{\styleBody}{\sizeThree\normalfont}

\newcommand{\styleOrg}{\sizeThree\bfseries}
\newcommand{\styleRole}{\sizeThree\itshape}

% Explicit styles for Education context
\newcommand{\styleEduSuffix}{\sizeThree\normalfont}
\newcommand{\styleEduRoleSuffix}{\sizeThree\itshape}

% --- Delimiters ---
\newcommand{\entrysep}{\space--\space}
\newcommand{\rolesep}{\space--\space}
\newcommand{\eduorgsep}{,\space}
\newcommand{\edurolesep}{,\space}

% =============================================================================
% INTERNAL LOGIC
% =============================================================================
\pagestyle{empty}
\pagenumbering{gobble}
\raggedright
\parindent=0pt

\newcommand{\divider}[1]{%
  \def\temp{#1}\def\h{header}\def\s{section}%
  \ifx\temp\h \vspace{\vHeaderRuleTop}\hrule height 1pt\vspace{\vHeaderRuleBot}
  \else\ifx\temp\s \vspace{\vSectionTop}\noindent{\styleSection\MakeUppercase{\thesectionname}}\par\vspace{\vSectionRuleTop}\hrule height 0.5pt\vspace{\vSectionRuleBot}\fi\fi
}

% =============================================================================
% INTERFACE (ENVIRONMENTS)
% =============================================================================

\newenvironment{resumeheader}[1]{
  \styleBody\noindent{\styleName #1}\par\divider{header}
  \begin{itemize*}[label={}, itemjoin={\enspace•\enspace}, nosep]
}{\end{itemize*}\par}

\RenewEnviron{section}[1]{\def\thesectionname{#1}\divider{section}\BODY}

\define@key{entry}{org}{\def\e@org{#1}}\define@key{entry}{city}{\def\e@city{#1}}\define@key{entry}{country}{\def\e@country{#1}}\define@key{entry}{suffix}{\def\e@suffix{#1}}
\newenvironment{entry}[2][]{ 
  \setkeys{entry}{org={}, city={}, country={}, suffix={}, #2}\styleBody\noindent
  \def\test{#1}\def\edu{edu}%
  \ifx\test\edu 
    \def\currentcontext{edu}{\styleOrg \e@org}\ifx\e@suffix\empty\else \eduorgsep {\styleEduSuffix \e@suffix}\fi
  \else 
    \def\currentcontext{std}{\styleOrg \e@org}\ifx\e@suffix\empty\else \entrysep {\styleOrg \e@suffix}\fi 
  \fi
  \hfill {\normalfont \e@city, \e@country}\par
}{\vspace{\vEntryEnd}}

\define@key{role}{title}{\def\r@title{#1}}\define@key{role}{start}{\def\r@start{#1}}\define@key{role}{end}{\def\r@end{#1}}\define@key{role}{suffix}{\def\r@suffix{#1}}
\newcommand{\role}[1]{
  \setkeys{role}{title={}, start={}, end={}, suffix={}, #1}\noindent
  {\styleRole \r@title}\ifx\r@suffix\empty\else
    \def\edu{edu}\ifx\currentcontext\edu \edurolesep {\styleEduRoleSuffix \r@suffix} \else \rolesep {\styleRole \r@suffix} \fi
  \fi
  \hfill {\normalfont \r@start\ --\ \r@end}\par
}

\newenvironment{highlights}{
  \vspace{\vRoleToHighlight}
  \begin{itemize}[
    leftmargin=\vHighlightIndent, 
    labelsep=\vHighlightLabelSep, 
    nosep, 
    topsep=0pt, 
    partopsep=0pt, 
    parsep=0pt, 
    itemsep=\vHighlightSep, 
    label=\small\textbullet
  ]
}{\end{itemize}}
\newcommand{\highlight}[1]{\item #1}

\newenvironment{details}[1]{\styleBody\noindent\textbf{#1:}\space\begin{itemize*}[label={}, itemjoin={,\space}, nosep]}{\end{itemize*}\par}