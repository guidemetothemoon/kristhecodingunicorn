+++
author = "Kristina D."
title = "Takeaways from attending KubeCon+CloudNativeCon Europe 2023, wearing many hats"
date = "2023-05-01"
description = "In this blog post I will share my reflections and takeaways from attending KubeCon+CloudNativeCon Europe 2023 wearing multiple hats: speaker, CNCF ambassador, KCD organizer and attendee."
draft = true
tags = [
    "kubernetes",
    "aks",
    "k8s",
    "cloudnative",
    "cncf",
    "devops",
    "gitops",
    "platformengineering"
]
+++

![Article banner for KubeCon and CloudNativeCon Europe 2023 takeaways](../../images/kubecon_cloudnativecon_eu_2023/blog_post_banner.webp)

{{< table_of_contents >}}

For over a week ago, 18th-21st of April, KubeCon+CloudNativeCon Europe was happening in Amsterdam in the Netherlands and it was HUGE! With a fully sold out event, with more than 10 000 participants and 20 parallell tracks, it has been the largest conference I've attended in-person so far. I attended the event wearing many hats: a speaker, KCD organizer, CNCF ambassador and an attendee. Having these roles gave me an even broader perspective of the event which I want to share with the community😺

I have also done a re-cap of the event together with Michael Levan in our new Kubernetes Unpacked podcast episode, where we talked about not only the latest and greatest technologies that are coming, but also about the top three takeaways from KubeCon+CloudNativeCon EU that you should remember when implementing Kubernetes in production. The episode is available here: []()

Overall I need to say that the event has been extremely-well organized - kudos to everyone involved! What specifically caught my attention were all the small things related to accessibility and inclusion: gender pronouns stickers, communication preference stickers and greeting preferences pins, all-gender bathrooms, tasty vegan food options, creative corner where you could draw or build lego, handicap accessibility, professional security and crowd management, and probably much more. It was clear that the event organization was extremelly well thought through in order to make it as inclusive, safe and accessible for everyone as possible.

What about the content?🤔

## Trends and session highlights

With 20 parallell tracks it becomes extremely challenging to prioritize and it's humanly impossible to attend all of the sessions in-person. Fortunately there are recordings available on YouTube, and I'm still going through those, but I would like to share with you some the sessions that I enjoyed.

General trends I've pointed out for myself in terms of content and interest from the community:

🪷 ***Multi-Everything: multi-cloud, multi-cluster, multi-tenancy.*** When it comes to enterprise reality, the answer is not always black and white. Many implementation projects become pretty complicated due to requirements like hybrid workloads or multi-cloud infrastructure. How to implement it in a secure, scalable and production-ready way? Quite a few sessions shed light on this topic and demonstrate some of the tools like Cilium, ArgoCD, Crossplane and a few others that can make the implementation journey easier for the organizations.

🪷 ***GitOps.*** This domain was also getting a lot of attention, both from the perspective of tools, but also organizational culture and processes. There were some good sessions that were about running GitOps tools in production, at scale. There was also a very good panel discussion where attendees could bring up their own challenges with implementing GitOps in enterprise setting.

🪷 ***Networking.*** This domain will always be relevant when it comes to Kubernetes, because networking in Kubernetes is advanced and requires times, patience and good helper tools to master. During the conference many sessions were dedicated to service mesh, eBPF, network policies. It was especially interesting to look into more advanced use cases with clusters running in different cloud offerings or in highly restricted environments.

🪷 ***Sustainability.*** My personal favorite. Sustainability in tech is clearly an emerging domain that is gaining more attention from the community. It was great seeing multiple sessions related to sustainability, as well as gaining visibility for TAG Environmental Sustainability. This domain is all about reducing our impact on climate change in tech industry and cloud native space: by reducing energy consumtion, wasted resources, carbon and water footprint. I'm really happy that I could contribute with my presentation to spreading awareness on this topic. It's clear that this domain will get even more attention in the future.

Below I would like to highlight some of the sessions that I really enjoyed, grouped by respective domains:

***GitOps***

- [How GitOps Changed Our Lives & Can Change Yours Too! - Priyanka Ravi, Weaveworks; Christian Hernandez, Red Hat; Filip Jansson, Strålfors; Roberth Strand, Amesto Fortytwo; Leigh Capili, VMware](https://youtu.be/hd7VkCLnTWk)

***Networking***

- [Adopting Network Policies in Highly Secure Environments - Raymond de Jong, Isovalent](https://youtu.be/yikVhGM2ye8)

- [Keeping It Simple: Cilium Networking for Multicloud Kubernetes - Liz Rice, Isovalent](https://youtu.be/fJiuqRY5Oi4)

***Backstage***

- [How We Migrated Over 1000 Services to Backstage Using GitOps and Survived to Talk About It! - Shahar Shmaram & Ran Mansoor, AppsFlyer](https://youtu.be/2fCNqKxAtYo)

- [Paved Paths Leading the Way to Compliance - Kasper Borg Nissen & Brian Nielsen, Lunar](https://youtu.be/6T3Mf6pdg7E)

***Div Kubernetes topics***

- [Keynote: Enabling Real-Time Media in Kubernetes - Giles Heron, Principal Engineer, Cisco](https://youtu.be/1_cxXzhY4Xg)

- [Love, Death and Robots - with Wasm & K8s on Boston Dynamics Spot - Max Körbächer, Liquid Reply](https://youtu.be/UsjZSsWpdRo)

- [Unlocking Argo CD’s Hidden Tools for Chaos Engineering - Featuring VCluster and More - Dan Garfield & Brandon Phillips, Codefresh](https://youtu.be/Z0RB5SFs6fI)

***Community and open source***

- [Keynote: Gardens and Glaciers: Saving Knowledge Through Succession - Emily Fox, Apple](https://youtu.be/oKHD3yAyWss)

- [From Community to Customers - Kelsey Hightower, Google Cloud](https://youtu.be/eb0442K_zmY)

***Sustainability***

- [Keynote: Building a Sustainable, Carbon-Aware Cloud: Scale Workloads and Reduce Emissions - Jorge Palma, Principal PM Lead, Microsoft Azure](https://youtu.be/s7K7QkhWnFU)

- [Minimizing Energy Consumption in Bare Metal K8s Clusters - Marco Schröder & David Meder-Marouelli](https://youtu.be/jsBSNCuSI74)

- [Evolution of on-Node Adaptive Power Tuning - Atanas Atanasov, Intel & Rimma Iontel, Red Hat](https://youtu.be/_SqebJmYteQ)

***TAG Environmental Sustainability***

[The State of Green Software + Cloud Native - Leonard Vincent Simon Pahlke, Liquid Reply & Cara Delia](https://youtu.be/VCIdFHhp4No)

![Photo of TAG Environmental Sustainability logo sticker with KubeCon+CloudNativeCon EU flags in the background](../../images/kubecon_cloudnativecon_eu_2023/tag_env_sus_logo.webp)

## Takeaways and tips from...

There are some reflections and tips that I gathered from attending KubeCon+CloudNativeCon EU in multiple roles, and I hope that some of these reflections can be insightful for you or even inspire you to attend the conference next time. Maybe even in a new role as a speaker or CNCF Ambassador😉

### Attendee

As an attendee the conference of such scale can quickly become very overwhelming and quite many tend to get a fear of missing out. For me it was both challenging and crucial to keep a balance of participating in sessions, engaging with the community members and getting quiet, alone time to bring myself back and re-charge.

Here are a few tips that help me get the most out of the conference and at the same time take care of myself:
> ***- Plan beforehand which sessions you want to prioritize and attend in-person,*** for example for additional engagement with the speaker.     
>
> ***- Expect that plans may change in such a dynamic environment:*** sessions may get fully-booked before you get in or you meet an old friend and use some additional time to catch up. Make your peace with it, evaluate what you should prioritize there and then and what can be covered by alternative options (f.ex., session recordings) at a later point.
>
> ***- Don't be afraid to ask questions or provide constructive feedback to the speaker.*** Engagement boosts innovation, improvements and new ideas, and is always appreciated! There are no stupid questions and a lot of effort is put into making such events a safe and inclusive space for sharing your opinion on the topic or asking questions. If you're still hesitant, take a look at the code of conduct that all the attendees are obliged to follow - it will help you understand how the rest of the audience is expected to behave in situations like this.
>
> ***- Challenge yourself a bit and see if you can come out of the comfort zone and get to know a new community member.*** For example, I chose to go alone for lunch, but I didn't get to sit all by myself for too long😸 Quite promptly other attendees joined me and I got to know new people, engage in interesting conversations around cloud native technologies and network. You can learn a lot from the experience of others and at the same time contribute to making the event more inclusive.
>
> ***- Remember to eat, drink water and re-charge.*** It's easy to forget these basic things, but they're crucial if you want to have enough energy and focus throughout the whole event. For me, taking breaks and short walks outside, eating lunch outside to get some fresh helped a ton. Getting good, stable sleep also helped me lots to stay focused so I would definitely urge you to not downprioritize this.

![Photo of keynote room at KubeCon and CloudNativeCon Europe 2023, tightly packed with people](../../images/kubecon_cloudnativecon_eu_2023/keynote.webp)

Finally, please note that all the sessions are being recorded, and recordings are published in a matter of 1-2 weeks after the event so you can always catch up with the rest of the sessions at a later point. For instance, the playlist from KubeCon+CloudNativeCon EU was published after ca. one week and is available here: [KubeCon + CloudNativeCon Europe 2023](https://youtube.com/playlist?list=PLj6h78yzYM2PyrvCoOii4rAopBswfz1p7).

### Speaker

Speaking at KubeCon+CloudNativeCon EU has become one of the greatest achievement for me as a technical speaker. I always looked up to the speakers presenting at conferences of such scale, and I have always thought that there is almost no chance to get in as a "smaller", less known content creator or tech community member. I was proven wrong. I had an idea, a topic I am extremely passionate about, that I wanted to share with the world and with the tech community. I was eager to talk about it and I took a chance and submitted a proposal...and I got chosen. Next time it can be YOU. 👋

> **If you have learned something that you feel others can benefit from in the community, you should definitely share it. If you have learned something that can become a talk, you should go for it and apply to the events that resonate with you. Independent of how big or popular those events are. It's scary, yes, but you're not missing anything by applying. You may miss on a lot though if you don't apply**😊   

![Photo of Kristina Devochko on stage at KubeCon and CloudNativeCon Europe 2023 presenting her session on sustainability in Kubernetes](../../images/kubecon_cloudnativecon_eu_2023/speaker_photo.webp)

My presentation at KubeCon+CloudNativeCon EU felt extra special because I got a chance to talk about something that I'm very focused on both in my personal and work life - sustainability. I talked about how sustainable software engineering principles can be applied to Kubernetes and it’s workloads, and what concrete actions you can take in order to make your Kubernetes workloads more eco-friendly. The engagement was really good and I enjoyed all the discussions my presentation sparked - as I mentioned in the section above, sustainability in tech is finally getting more attention and engagement from the community and I'm looking forward to contributing to even bigger focus on the importance of this area of software development.

🚀 If you would like to know more about the topic I covered during my presentation, the recording is available on YouTube: [Be the Change Our Planet Seeks: How YOU Can Contribute to Running Environment-Friendly Workloads on Kubernetes - by Kristina Devochko](https://youtu.be/ppe0ptZEcvw)

### CNCF Ambassador

CNCF Ambassadors are an extension of CNCF, furthering the mission of "making cloud native ubiquitous" through community leadership and mentorship.
CNCF Ambassadors are elected twice per year and anyone can apply. If you're contributing back to the cloud native and open source community by creating technical content, organizing events, speaking or mentoring, you should consider applying for the program. Here's a summary of Spring 2023 election which was the first term I got accepted to: [Introducing our Spring 2023 Cloud Native Ambassadors! ](https://www.cncf.io/blog/2023/04/19/introducing-our-spring-2023-cloud-native-ambassadors)

> **KubeCon+CloudNativeCon EU was a great opportunity to meet fellow ambassadors from all over the world and engage in interesting discussions around cloud native technologies, content creation and community contribution. It's also a great arena to brainstorm new content and collaborate on creating some of that content together to bring even more value to the community.**

![Photo of CNCF Ambassadors logo on a black jacket with cherry blossoms in the background](../../images/kubecon_cloudnativecon_eu_2023/cncf_ambassadors_logo.webp)

Another reflection I really want to share is ***the atmosphere of inclusion***. I'm an introvert and am not always mastering social events and get-to-know parties in a good way, therefore attending events where I don't know that many people can quickly become challenging. As part of the conference I attended an Ambassador breakfast for all the CNCF Ambassadors, where I didn't know that many just yet. As I was about to sit down for myself, a few other ambassadors spotted it and invited me to their table, which was very sweet and nice of them to do. I would like to send these kind fellow ambassadors a shoutout and a warm Thank You for including me in their company - people like you give me even more inspiration to do the same when I see someone who may feel lonely or uncomfortable at community events💖

### KCD Organizer

![Kubernetes Community Days logo](../../images/kubecon_cloudnativecon_eu_2023/kcd_banner.webp)

Kubernetes Community Days (KCD) are smaller versions of KubeCon+CloudNativeCon that are arranged by tech community members all over the globe, with support from CNCF. The goal of these events is to foster collaboration, networking, knowledge sharing around topics of open source, cloud native and Kubernetes in the local tech communities. 

Any city can arrange a KCD and there's a helpful checklist with extensive information available on GitHub that can come in handy if you consider arranging a KCD event yourself at some point: [cncf/kubernetes-community-days](https://github.com/cncf/kubernetes-community-days).

> **During KubeCon+CloudNativeCon EU there were multiple opportunities to engage with fellow KCD organizers, both new and experienced ones. There was a booth available where at any time you could go and have a chat with some of the KCD organizers about anything around event planning, tips and tricks, etc.**

🚀 I recommend you to check out following session: [Grow Your Own Community! Lessons Learned from Running Kubernetes Community Days Across Europe - Matt Jarvis, Snyk; Annalisa Gennaro, SparkFabrik; Max Korbacher, Liquid Reply; Alessandro Vozza, Solo.io; Paula Kennedy, Syntasso](https://youtu.be/Ako9eAcMQfY). This was a very interesting panel discussion where organizers from some of the biggest Kubernetes Community Days in Europe shared their experiences, challenges, pitfalls, tips and tricks when it comes to organizing such community events at scale.

Myself, together with a few amazing community members, will be arranging KCD Norway in January 2024 so if you're planning a trip to Oslo or would like to speak at our event, do reach out! All the updates regarding the event will be published at [CNCF - KCD Norway](https://community.cncf.io/kcd-norway), so stay tuned!😼

That's it from me this time, thanks for checking in!💖

If this article was helpful, I'd love to hear about it! You can reach out to me on LinkedIn, Twitter, GitHub or by using the contact form on this page.😺

Stay secure, stay safe.

Till we connect again!😻