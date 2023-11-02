+++
author = "Kristina D."
title = "A bird's-eye view of upcoming KubeCon+CloudNativeCon North America 2023"
date = "2023-10-31"
description = "In this blog post I will share my perspective for the upcoming KubeCon+CloudNativeCon North America 2023: trends, what to expect and share personal tips about getting the most out of the event."
draft = true
tags = [
    "kubernetes",
    "aks",
    "k8s",
    "cloudnative",
    "cncf",
    "devops",
    "gitops",
    "platformengineering",
    "kubecon",
    "cloudnativecon"
]
slug = "kubecon-cloudnativecon-na-2023-expectations"
+++

{{< table_of_contents >}}

[KubeCon + CloudNativeCon North America 2023](https://events.linuxfoundation.org/kubecon-cloudnativecon-north-america) is under a week away and I thought I would use this opportunity to share some of the personal reflections for the upcoming event, as well as highlight some of the sessions that I personally am looking forward to watching.

Myself and Michael have also chatted about the event at **Kubernetes Unpacked podcast** - do check out this episode as well: [KubeCon NA 2023 Prep](https://packetpushers.net/podcast/kubernetes-unpacked-TODO).

This time I'll be joining the event virtually, but this doesn't take away the fact that the event agenda is quite large and can at times be a little bit overwhelming...as always 😅 After using some time to go through the agenda I can say that there will be quite many sessions on security - there will be both "formal" sessions, Capture The Flag (CTF) and Unconference sessions, where participants will choose themselves which topics from the list they want to have a discussion about. Previously there was a Security Village at KubeCon+CloudNativeCon EU, but now it's called a **Security Hub**.

There will also be an **AI Hub**, which is new - it will be purely in Unconference format and touch upon topics of LLMs, AI policy, AI operations, AI data governance and usage of AI in organizations. In general I feel that, even compared to the EU event which was half a year ago, there's a significantly larger presence of sessions related to AI and Machine Learning in context of Kubernetes in the NA event, which is not surprising if we look at how rapidly the artificial intelligence space has evolved. There will also be a pre-day event dedicated to [Kubernetes AI and high-performance computing (HPC)](https://sched.co/1RIUk).

While we are on the topic of pre-day and co-located events I would like to highlight [AppDeveloperCon](https://sched.co/1RIQk), which is a new type of co-located event hosted by CNCF. This event is specifically targeting application developers and will cover topics related to the architecture, design, and development of cloud native applications. Another co-located event I'd like to highlight is [DBaaS DevDay](https://sched.co/1RITM), which is all about development and utilization of cloud native databases and how it fits into the cloud native ecosystem and Kubernetes. By now we know that running stateful workloads on Kubernetes is totally possible, as long as you have a meaningful use case for it 😉

There are so many good sessions and it's so challenging to choose which ones to prioritize, but here comes some of my personal session highlights that I'm looking forward to:

- 🌟 [Environmental Sustainability in the Cloud Is Not a Mythical Creature](https://sched.co/1R4Tl) keynote, where the panel will discuss initiatives to monitor and address sustainability-related challenges in technology sector. Some of my fellow [TAG Environmental Sustainability](https://tag-env-sustainability.cncf.io/) members will also be part of the panel. In addition to the keynote there are a few other sustainability-related sessions that I'm looking forward to: [Cutting Climate Costs with Kubernetes and CAPI](https://sched.co/1R2p6), [Sustainable Scaling of Kubernetes Workloads with In-Place Pod Resize and Predictive AI](https://sched.co/1R2nS) and [Environmentally Sustainable AI via Power-Aware Batch Scheduling](https://sched.co/1R2tJ).

- 🌟 [15,000 Minecraft Players Vs One K8s Cluster. Who Wins?](https://sched.co/1R2lz) session which is super interesting in terms of how to run at scale and scale fast on bare metal Kubernetes infrastructure.

- 🌟 [Deploying Kubernetes in Classified Environments](https://sched.co/1R2m3) and [Software Delivery in Regulated Environments: Critical Infrastructure Needs a Community Approach](https://sched.co/1R2si) sessions. I always find complicated use cases like this, with high level of security requirements and implementation limitations to be extremely interesting and insightful. It will be interesting to learn from real-life projects about delivering mission-critical platforms based upon Kubernetes and other CNCF tools.

- 🌟 A few interesting project stories that caught my eye: [“The Stars Look Very Different Today”: Kubernetes and Cloud Native at the SKA Observatory](https://sched.co/1R2tP) about how cloud native solutions are successfully adopted at The SKA Observatory (SKAO), a next-generation radio astronomy-driven Big Data facility currently under construction in South Africa and Australia; and [The Way We Build the Largest Public and Private Cloud Infrastructure in Vietnam](https://sched.co/1R2qz) about how the biggest Telco in Vietnam builds and manages its infrastructure by utilizing open source projects from the CNCF ecosystem.

- 🌟 A few GitOps and Platform Engineering related sessions: [Building, Scaling, and Growing Internal Developer Platform for Companies Inside Companies](https://sched.co/1R2md), where GoTo Financial will share experiences and challenges with onboarding multiple engineering teams to their self-service IDP; [Everything Is Code: Embracing GitOps at Spotify](https://sched.co/1R2qU) about developer-centric, all-as-code approach that Spotify follows; and [Harnessing Argo & Flux: The Quest to Scale Add-Ons Beyond 10k Clusters](https://sched.co/1R2mf) about running GitOps tools at scale. In this specific session presenters will talk about Flamingo, that is a newer open source tool that's sponsored by Weaveworks, that can provide capabilities of combining strengths of FluxCD and Argo CD for reducing complexity of implementing GitOps at scale.

- 🌟 [SECURITY HUB: Making Kubernetes Quantum-Safe: what can we do to protect ourselves now?](https://sched.co/1SKeZ): with advancements in quantum computing the threats to current cryptography standards are more real than ever, therefore I have been closely following the development of quantum-safe cryptography and respective post-quantum cryptography standards. It will be interesting to learn how these standards can be looked at in context of Kubernetes.

- 🌟 A few cloud native beginner sessions that are worth mentioning: [Learning Kubernetes by Chaos – Breaking a Kubernetes Cluster to Understand the Components](https://sched.co/1R2r7), where you can learn about how different components in Kubernetes hang together by simulating failures. A lightweight version of chaos engineering experiments with learning from failures approach - I like it! Also, I would like to mention a session the format of which I find very creative - [Dungeons and Deployments: Leveling up in Kubernetes](https://sched.co/1Tbpo), where you get to learn fundamental Kubernetes concepts in a gamified way, through a variation of Dungeons & Dragons game - this sounds like a fun session to attend which I believe will be very engaging to follow along with! Don't miss out on those, especially if you're a beginner in this space.

Finally I want to highlight a new activity that I hope will make it to the KubeCon+CloudNativeCon EU in March next year: [CLBO: ClashLoopBackOff](https://sched.co/1T3oc), where some of my fellow CNCF Ambassadors will be competing in solving challenges and fixing a broken cluster or deploying a service to production. Submitted entries will be judged based on stability, resiliency, flexibility and observability. Sounds super fun! If it will be arranged during the EU event I will need to ensure that I'm part of it 😸

All in all I feel like there's a lot of useful and insightful content on the agenda for KubeCon+CloudNativeCon North America 2023 and I will definitely be going through some of the recordings even after the event is finished.

In terms of overall observations I also think that CNCF does a great work for the community by organizing the [Kid's Day](https://events.linuxfoundation.org/kubecon-cloudnativecon-north-america/program/kids-day), which is a free event taking place the day before the conference start and is tailored specifically for children aged 8 to 14. In addition I think it's great that CNCF was offering 200 free tickets for those affected by job loss or budget freeze.

To round up on the topic I've been asked a few times about how you can get most out of the event, especially if you're an introvert or get extremely overwhelmed by events of such scale. I can fully relate to that and can recommend to:

- 🌷 Build your schedule in advance in the app and ensure that you have some breaks in-between sessions to stay focused and have some context switching;

- 🌷 Be there early for sessions that have very well-known presenters or are related to the "hot" topics like running Kubernetes clusters at scale! Meet up at least **20-30 minutes before** session start. I've learned it the hard way and it's better to get there early if you really want to experience the session in-person. Please note that you can still watch the live stream of all the sessions if you nevertheless don't get a spot. All the session recordings will also be published a few weeks after the event.

- 🌷 Follow the 4 GETs: get enough **SLEEP**, get enough **BREAKS**, get enough **WATER** and get enough **NUTRITION**. It's easy to forget and underestimate the power and importance of the 4 GETs at large, dynamic events like this.

- 🌷 Join some of the social community events like [Kuberoke](https://kuberoke.love) which typically arranges Karaoke evenings for the Kubernetes community during KubeCon+CloudNativeCon events, or [SIG Boba](https://sig-boba.github.io) which offers bubble tea, french fries, welcoming and inclusive company and more,  and is open for everyone from the cloud native and open source community. But remember: it's totally OK to take a step back and re-charge if you feel drained for energy 🙌

**Summing it up:** KubeCon+CloudNativeCon North America 2023 will definitely be a great event filled with great content and great people from the community. If you're going there in-person I hope that you'll enjoy it to the fullest!

That's it from me this time, thanks for checking in!💖

If this article was helpful, I'd love to hear about it! You can reach out to me on LinkedIn, Twitter, GitHub or by using the contact form on this page.😺

Stay secure, stay safe.

Till we connect again!😻
