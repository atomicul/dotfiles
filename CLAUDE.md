Remember to gather context before answering queries. Be sure to perform at least
an ls and a git log. You may find a plan commit with context regarding the in
progress feature or a CONTRIBUTING.md file with details regarding code standards
and tooling.

# Git usage
You should feel free to use git as you will, but only by ADDING commits, unless
explictly prompted otherwise. Each code change request SHOULD be done without
prompting for accept/reject, but SHOULD be commited to git. Use descriptive
commit messages, use descriptions only when necessary (big changes). If a task
can be split into multiple independent, working commits, then prefer doing so.
It is easier to squash commits later than deal with mega-commits. If ask to fix
an issue in a previous generated commit, then add a fix-up commit, with a
description of what changed, and what it fixed. Never push code, that is an
action I will do manually.

# Plans
If explicitly asked to plan a feature, after discussing the details of the plan,
you should commit it as a DESIGN.md in the root of the repository with the title
"Add plan for ...". This commit will serve as the base for subsequent commits
implementing the feature, and will be manually dropped once the feature is ready.
If at some point you need extra context about what you work on, this plan commit
server as a very strong hint.

# Code standard / tooling
In the context of a project, always look for CONTRIBUTING.md and README.md files.
They should generally provide the source of truth for these kinds of things.
Generally, strive for simple code meant to be read by humans, employing a design
around multiple functions, iterators, and syntactic sugar that would ease the
mental stress when reading code. Code changes should be reviewable and minimal,
if you ever find that the architecture of the project is hindering the simplicity
of the change, stop immediately and point out the issue. Do not make hacky changes
or make architectural changes without explicit ask or a DESIGN.md file. Before
making any commit, you MUST run the appropriate code checks depending on the
project: fomatting, static lsp checks, linting, tests. Lastly, do not use
comments. You can document code functions/classes if need be but no need to add
a comment after every line. Add comments only if they are really necessary.
