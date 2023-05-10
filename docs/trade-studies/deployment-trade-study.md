# Trade Study: Deployment Tools

|                 |                  |
| --------------: | ---------------- |
| _Conducted by:_ | Luisa de Miranda |
|  _Sprint Name:_ | 1                |
|         _Date:_ | April 2021       |
|     _Decision:_ | Terraform        |

## Overview

This study considers how we should deploy our solution to Azure. Possible
options include:

- Bicep (Preview)
- Terraform

## Goals

Choose a tool for continuous deployment of the full Virtual Court solution to
Azure. We expect to provision and update numerous pieces of IaaS and PaaS. There
is no expectation that we will ever require a multi-cloud solution. Both
potential solutions are open source and supported by Microsoft developers. Both
are simple downloads and command line interfaces.

## Open questions

- Do we want to try Bicep for the sake of upskilling our team and partner
  engineers?

### Solution 1 - Bicep

Bicep is a declarative abstraction over ARM templates for Infrastructure as
Code. It is much easier to read and write than ARM templates. It is quite
similar syntactically to Terraform, but compiles to JSON ARM templates. It is
only usable with Azure. Bicep has instant feature parity with ARM templates,
because it basically is ARM Templates. The biggest hurdle to using Bicep is that
the documentation is not complete - it may require users to effectively learn
ARM Templates to write it. See [Jon Gallant's description of finding
"documentation"](https://youtu.be/3lTrIgTJ9yc?t=1210). Bicep has the advantage
of not requiring a state file, which by storing secrets in plain text, can
potentially be a security risk. By not requiring a state file, Bicep could
eventually be better for security.

[Getting started with Bicep](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview)

Snippet:

```BCL
resource aks 'Microsoft.ContainerService/managedClusters@2020-09-01' = {
  name: '${basename}aks'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: '1.20.2'
    nodeResourceGroup: '${basename}aksnodes'
    dnsPrefix: '${basename}aks'

    agentPoolProfiles: [
      {
        name: 'default'
        count: 1
        vmSize: 'Standard_A2_v2'
        mode: 'System'
      }
    ]
  }
}
```

#### Pros

- Full parity with ARM templates
- Part of az cli (but separate installation is still recommended)
- Pulls state directly from Azure rather than state file

#### Cons

- Still in preview
- Only usable with Azure
- Immature documentation, Intellisense, validation - best if you already know ARM
- Partner engineers probably unfamiliar with it
- Lower level language is less clear and intuitive overall (e.g. object
  properties such as id and connection string aren't always perfectly read from
  the object)
- Lacks some actions, such as "plan" available in Terraform

### Solution 2 - Terraform

Terraform is declarative infrastructure as code. It has many modules for
provisioning and updating infrastructure across all cloud providers and has a
strong community, including Microsoft engineers, contributing to its
functionality. It is considered a first party tool by Microsoft Product Groups.
It also has complete documentation and validation. Terraform keeps the state of
the infrastructure in state files, which keep everything, including secrets, in
plaintext. They can be stored encrypted, but if someone gets access to the
storage account with the state file, it could be a security risk.

[Getting started with Terraform on Azure](https://learn.hashicorp.com/collections/terraform/azure-get-started)

Snippet:

```HCL
resource "azurerm_container_registry" "acr" {
  name                = "${var.basename}acr"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  admin_enabled       = true
}
```

#### Pros

- Commonly used - likely to be known already by partner engineers
- More mature documentation
- More intuitive language (e.g. aliasing, object property access)
- Has a test suite - terratest
- Supports multi-cloud deployment, though not a concern for this project.
- Discussion in CSE Solution Area support its use over Bicep at the moment

#### Cons

- Can lag behind feature parity with ARM templates
- Pulls state from file rather than directly from Azure

### ARM Templates

ARM Templates are JSON, and they are notoriously difficult to write and
maintain. Terraform is the standard replacement for them within CSE and
elsewhere, so ARM Templates were not considered.

### az-cli

Azure cli is a good solution for small, simple projects, or for developing and
testing, but they are not Infrastructure as Code at all. Scripts are difficult
to write and maintain for a project of any complexity, so az-cli was not
considered.

### Comparison

The table below summarizes the differences between the solutions:

| Solution  | Support                               | Documentation      | Partner preferences                  |
| --------- | ------------------------------------- | ------------------ | ------------------------------------ |
| Bicep     | Microsoft 1st party - full ARM parity | In development     | Most partner engineers will not know |
| Terraform | Microsoft 1st party - parity can lag  | Mature development | Well known to developers             |

### Decision

Terrraform is a significantly more mature tool, with mature documentation. It is
better supported and better known, especially outside Microsoft. Unless the
partner has a preference for Bicep, due to its faster parity with ARM templates,
it is recommended (including with CSE Solution Area) to continue using Terraform
until Bicep is more complete.
