# Terraform-Associate-004

Hello and welcome to the combined repository for my Terraform Associate 004 learning path on Pluralsight! The path is broken up into six courses:

* [Terraform Fundamentals](https://app.pluralsight.com/ilx/video-courses/terraform-fundamentals-iac-providers-state-004-cert)
* Core Terraform Workflow
* Terraform Configuration
* Terraform Modules
* Terraform State
* HCP Terraform

Each course deals with some portion of the objectives outlined by the [exam materials on HashiCorp's site](https://developer.hashicorp.com/terraform/tutorials/certification-004/associate-review-004).

Currently, the `Terraform Fundamentals` and `Core Terraform Workflow` courses have been published.

As each course is published, a new folder will be added to the repository. The current plan is to have all courses published by end of June 2026.

## Expectations

The purposes of these courses and the learning path as a whole is to prepare you to take the Terraform Associate 004 exam and achieve the certification. While the courses also provide you with baseline knowledge necessary to use Terraform, they are not as comprehensive as my other series of courses in the [standard Terraform learning path](https://app.pluralsight.com/paths/skill/terraform).

Most of the examples provided in the exercises focus on using Terraform and not a particular public cloud platform. I chose to do this for two reasons. First, the exam is intentionally cloud agnostic, so gaining expertise in AWS or Azure will not help you pass the exam. And secondly, leveraging a cloud platform costs money and requires additional setup. By sticking to providers like `local` and `random`, you can gain an understanding of how Terraform works without dealing with costly cloud resources and account credentials.

Of course, if you plan to use Terraform in a production context, you will need to learn how to use providers that deal with specific cloud platforms. In that case, you may wish to seek out some of the platform specific Terraform courses on Pluralsight. Again, this path is intended to help you pass the exam; no more, no less.

## Course to Objective Mapping

In case you are trying to focus on a specific objective, I have created the table below to help map objectives to the relevant course:

| Objective Type | Objective | Course |
| --- | --- | --- |
| Top-level | Infrastructure as Code (IaC) with Terraform | Terraform Fundamentals: Infrastructure as Code, Providers, and State |
| Sub-objective | Explain what IaC is | Terraform Fundamentals: Infrastructure as Code, Providers, and State |
| Sub-objective | Describe the advantages of IaC patterns | Terraform Fundamentals: Infrastructure as Code, Providers, and State |
| Sub-objective | Explain how Terraform manages multi-cloud, hybrid cloud, and service-agnostic workflows | Terraform Fundamentals: Infrastructure as Code, Providers, and State |
| Top-level | Terraform fundamentals | Terraform Fundamentals: Infrastructure as Code, Providers, and State |
| Sub-objective | Install and version Terraform providers | Core Terraform Workflow for Terraform Associate (004) |
| Sub-objective | Describe how Terraform uses providers | Terraform Fundamentals: Infrastructure as Code, Providers, and State |
| Sub-objective | Write Terraform configuration using multiple providers | Terraform Configuration for Terraform Associate (004) |
| Sub-objective | Explain how Terraform uses and manages state | Terraform Fundamentals: Infrastructure as Code, Providers, and State |
| Top-level | Core Terraform workflow | Core Terraform Workflow |
| Sub-objective | Describe the Terraform workflow | Core Terraform Workflow |
| Sub-objective | Initialize a Terraform working directory | Core Terraform Workflow |
| Sub-objective | Validate a Terraform configuration | Core Terraform Workflow |
| Sub-objective | Generate and review an execution plan for Terraform | Core Terraform Workflow |
| Sub-objective | Apply changes to infrastructure with Terraform | Core Terraform Workflow |
| Sub-objective | Destroy Terraform-managed infrastructure | Core Terraform Workflow |
| Sub-objective | Apply formatting and style adjustments to a configuration | Core Terraform Workflow |
| Top-level | Terraform configuration | Terraform Configuration |
| Sub-objective | Use and differentiate resource and data blocks | Terraform Configuration |
| Sub-objective | Refer to resource attributes and create cross-resource references | Terraform Configuration |
| Sub-objective | Use variables and outputs | Terraform Configuration |
| Sub-objective | Understand and use complex types | Terraform Configuration |
| Sub-objective | Write dynamic configuration using expressions and functions | Terraform Configuration |
| Sub-objective | Define resource dependencies in configuration | Terraform Configuration |
| Sub-objective | Validate configuration using custom conditions | Terraform Configuration |
| Sub-objective | Understand best practices for managing sensitive data, including secrets management with Vault | Terraform Configuration |
| Top-level | Terraform modules | Terraform Modules |
| Sub-objective | Explain how Terraform sources modules | Terraform Modules |
| Sub-objective | Describe variable scope within modules | Terraform Modules |
| Sub-objective | Use modules in configuration | Terraform Modules |
| Sub-objective | Manage module versions | Terraform Modules |
| Top-level | Terraform state management | Terraform State and Infrastructure Lifecycle |
| Sub-objective | Describe the local backend | Terraform State and Infrastructure Lifecycle |
| Sub-objective | Describe state locking | Terraform State and Infrastructure Lifecycle |
| Sub-objective | Configure remote state using the backend block | Terraform State and Infrastructure Lifecycle |
| Sub-objective | Manage resource drift and Terraform state | Terraform State and Infrastructure Lifecycle |
| Top-level | Maintain infrastructure with Terraform | Terraform State and Infrastructure Lifecycle |
| Sub-objective | Import existing infrastructure into your Terraform workspace | Terraform State and Infrastructure Lifecycle |
| Sub-objective | Use the CLI to inspect state | Terraform State and Infrastructure Lifecycle |
| Sub-objective | Describe when and how to use verbose logging | Terraform State and Infrastructure Lifecycle |
| Top-level | HCP Terraform | HCP Terraform |
| Sub-objective | Use HCP Terraform to create infrastructure | HCP Terraform |
| Sub-objective | Describe HCP Terraform collaboration and governance features | HCP Terraform |
| Sub-objective | Describe how to organize and use HCP Terraform workspaces and projects | HCP Terraform |
| Sub-objective | Configure and use HCP Terraform integration | HCP Terraform |
