+++
author = "Kristina D."
title = "Passing Kubernetes and Cloud Native Associate (KCNA) certification exam"
date = "2023-11-02"
description = "In this blog post I will share my experience from passing KCNA certification exam. I will also share resources and tips and tricks from prepraring for and taking the exam."
draft = true
tags = [
    "kubernetes",
    "kcna",
    "k8s",
    "cloudnative",
    "cncf"
]
slug = "passing-kcna-certification-exam"
+++

{{< table_of_contents >}}

For some time ago I successfully passed a Kubernetes and Cloud Native Associate (KCNA) certification exam from CNCF and The Linux Foundation, and in this blog post I would like to share a few resources I've used for preparation, as well as a few personal experiences from the certification exam and format, that I hope can be useful for others who are getting ready for the exam 😺

## What is KCNA?

[Kubernetes and Cloud Native Associate (KCNA)](https://www.cncf.io/certification/kcna) is one of the beginner-level certifications that verifies your fundamental knowledge of cloud native technologies. Significant part of the certification is dedicated to Kubernetes, its architecture and core components, but it also covers areas like containerization, GitOps and fundamental cloud native security.

KCNA certification is valid for **3** years and can be a good preparation for more advanced certification exams like CKAD, CKA and CKS.

## KCNA exam format

KCNA exam is an online, proctored exam that lasts for **90 minutes**. It's a multiple choice type exam with **60** questions, where you only have questions with a single correct answer, i.e. there are no multi-choice questions. I've completed my exam in 30 minutes, but this is because I've worked with Kubernetes and cloud native technologies for some time now, but I do believe that 90 minutes should be enough time if you're a beginner and have invested some time for preparations.

Once you complete the exam you will not get your results straight away. You should receive your results approximately **24 hours** after the exam and from my experience, it **will** take no less than 24 hours so there's no need for you to refresh your e-mail any earlier than that 😁

## Expectations and Experiences

After successfully passing the exam I gathered a few personal experiences and observations that I hope can come in handy for others who will be preparing for the KCNA exam:

- ✅ **Join early and check your equipment extensively.** This is a general recommendation that's extremely important for all the home exams you will be taking. There are many things that need to be done before you can actually start the exam: download secure browser, test that it works, test your video, audio and network connection, etc. All of it takes time and issues may pop up even if you did a test the day before. Please note that you will also need to film every single corner of the room and yourself to the proctor which also takes time so logging in 30 minutes before the exam start is a very good idea so that you don't need to stress in case any issues may occur. I was for example using Ubuntu and had to do some graphic card re-configuration for the secure browser to work so it did take longer time to get everything ready than maybe the exam itself 😅 One last thing here is to ensure that you have a strong internet connection. If you can use cable, it's even better than Wi-Fi, but if you're using Wi-Fi, do run a few speed tests to ensure that the signal is really good. If you will be breaking up during the exam of if your video freezes multiple times during the exam there's a high risk that the proctor will cancel the exam attempt and request you to re-schedule, so it's better to be on the safe side here and do your best to have a solid internet connection during the exam.

- ✅ **Don't prioritize learning CNCF landscape and every project's maturity by heart.** I see that there are many courses and tutorials that mention that you need to know exactly which CNCF projects are in sandbox, incubating or graduated state, but personally I think that the probability of getting this type of questions is very very low. The reason why I think this is because the CNCF landscape is extremely dynamic and there are a lot of changes happening constantly, both in terms of new projects being included in the landscape, but also existing projects transitioning between maturity states. Questions and answer validations would need to be updated and maintained very frequently and I don't think it's worth it. Besides such questions would not test your practical knowledge and understanding of cloud native technologies so I wouldn't use time to memorize every single project in the CNCF landscape and its current maturity status. As long as you have an overall overview and understanding of CNCF project lifecycle you should be good 😊

- ✅ **Dedicate time to get hands-on with basic Kubernetes commands.** During the exam there's a high chance that there will be questions where you would need to choose correct ```kubectl``` commands to resolve a specific problem. Getting hands-on interaction with Kubernetes objects and practically applying theoretical knowledge you've gained about Kubernetes will give you a significantly higher chance of A-cing this type of questions. I would definitely recommend having a [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet) nearby at all times during your preparation - it containes a great list of commonly used ```kubectl``` commands and flags.

- ✅ **Dedicate time for practice questions and mock exams.** Learning by doing is something I always recommend. Going through mock exams and sample questions will help you ground all the knowledge you've gained and let it stay in your head long-term. There's a reason for why there's a saying that practice makes perfect: it's been scientifically proving that having a routine and doing a specific activity regularly can positively change our brains. In this case it will make us better prepared for the actual exam questions.

## Preparation resources

I've used following resources for preparation, and I think that these are very good and cover many of the topics that can come up during the KCNA exam.

- ⭐️ [Kubernetes and Cloud Native Essentials (LFS250)](https://training.linuxfoundation.org/training/kubernetes-and-cloud-native-essentials-lfs250) course from The Linux Foundation is a good starting point and provides a good introduction to the different areas of cloud native like observability, application delivery and Kubernetes fundamentals. It's content correlates very well with the exam outline.

- ⭐️ ["The KCNA Book" by Nigel Poulton](https://leanpub.com/thekcnabook) is really good and goes more detailed through the topics that are covered in the LFS250 course. There are also control questions and final exam sample that will help you ensure that you've understood the basic concepts. I would also recommend Nigel's [The Kubernetes Book](https://leanpub.com/thekubernetesbook) which also has great walkthrough of Kubernetes fundamentals and provides detailed and easy-to-grasp explanations of Kubernetes architecture and its main components.

- ⭐️ My fellow CNCF ambassador, James Spurin, has launched an open [Kubernetes and Cloud Native Associate - Study Group](https://github.com/spurin/KCNA-Study-Group) in GitHub Discussions that is specifically meant to be a discussion and knowledge sharing forum among those who are pursuing the KCNA certification. I think that it can be a great place to learn from others, as well as ask questions in case you're struggling with understanding a specific topic.

- ⭐️ Finally, there's a lot of useful information about the exam format, requirements and rule in [The Linux Foundation Certification Exam Candidate Handsbook](https://docs.linuxfoundation.org/tc-docs/certification/lf-handbook2) so I would definitely recommend to go through it in advance to get a good overall picture of how the exam will look like, at least a few days before the scheduled exam date.

Good luck with the exam and if you have any questions regarding it, don't hesitate to reach out and I'll be happy to help!

That's it from me this time, thanks for checking in!💖

If this article was helpful, I'd love to hear about it! You can reach out to me on LinkedIn, Twitter, GitHub or by using the contact form on this page.😺

Stay secure, stay safe.

Till we connect again!😻
