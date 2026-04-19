cluster is for public accessed websites via cloudflare tunnels (for IP)

- use envoy gateway (or just Gateway API)
- use cilium for networking
- can use localpath-provisioner since this is single node (or longhorn if feasible)

- maybe add immich

---

What was your approach, workflow, assumptions, etc. when trying to solve this kube-prometheus-stack storage issue?
How did you do the things step by step?
What should we take note of when trying to migrate storageclasses?

My approach to this (if im going to do it manually) is to edit the values.yaml for the monitoring stack and then delete pvc and pv (so config sync from argocd will sync from git).
You can explain it comprehensively so that i would also learn from it.

Also, how did you patch the kubernetes cluster state with the fixes even if argocd sync doesn't match the one in git (since you're debugging on the fly and applying patches)?

---

Let's create a comprehensive plan for migrating my @cluster/ to @k8s-gitops/ with a few caveats:

- There will still be 2 gateways (internal and external), internal uses tailscale see @cluster/docs/ as well, and external will use cloudflare.
- I want to see how everything is structured in @k8s-gitops/ so tell me how things are approached here
- I also want to see a workflow on how to add things in this new cluster.
- Observability-wise, i want to know how this is done and how to extend/add more
