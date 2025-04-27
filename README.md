# Mood Mentor: Intelligent Health Analytics with fetch.ai uAgents

![tag:innovationlab](https://img.shields.io/badge/innovationlab-3D8BD3)
![tag:domain/health](https://img.shields.io/badge/domain-health-2FC14E)
![tag:wellbeing](https://img.shields.io/badge/wellbeing-FF6B6B)

**Description**: This AI system collects and analyzes personal health data from various sources to identify patterns, detect stressors, and provide personalized recommendations for improving mental and physical wellbeing. It processes data from wearables, screen time tracking, and journal entries to deliver actionable insights.

## Inspiration
In today's hyper-connected world, we're constantly bombarded with digital notifications, work pressures, and lifestyle challenges that affect our wellbeing. Despite having more health data than ever before through wearables and apps, most of us lack the tools to make sense of this information and identify what's truly impacting our mental and physical health.

Our team recognized this gap and asked: What if we could create an intelligent system that not only collects this scattered health data but actually analyzes it to identify personal stressors and provide actionable, evidence-based recommendations?

## What it does
Mood Mentor is a comprehensive health analytics platform built on fetch.ai's uAgents framework that transforms raw health data into personalized wellbeing insights. Our system:

1. **Collects and normalizes diverse health data** from wearables, screen time trackers, and personal journals
2. **Identifies patterns and correlations** between daily activities and health outcomes
3. **Detects personal stressors** affecting your wellbeing using advanced pattern analysis
4. **Generates personalized, evidence-based recommendations** to improve your mental and physical health

The platform presents this information through an intuitive mobile interface that shows current stressors with severity levels, allows for daily journaling of activities and emotions, and tracks key health metrics over time.

## How we built it
We architected Mood Mentor using a multi-agent system powered by fetch.ai's uAgents framework. Our system consists of four specialized autonomous agents:

1. **DataCollectionAgent**: Collects and preprocesses health and activity data from various sources, normalizing it for analysis.

2. **PatternAnalysisAgent**: Identifies correlations and patterns in the data using several techniques:
   - Time-series analysis to detect relationships between variables
   - Threshold detection to find critical trigger points
   - Clustering to determine "good day" vs "bad day" patterns
   - Analysis of journal entries to extract sentiment and topics

3. **RecommendationAgent**: Analyzes identified stressors and generates personalized recommendations based on evidence-backed interventions.

4. **ClientAgent**: Orchestrates the workflow between the other agents and provides the unified analysis to the user interface.

The frontend was built as a mobile-first web application that communicates with our agent system to display personalized insights and collect user inputs.

## Challenges we ran into
Building Mood Mentor presented several significant challenges:

1. **Data integration complexity**: Consolidating and normalizing data from diverse sources with different formats required sophisticated preprocessing.

2. **Pattern detection accuracy**: Identifying meaningful patterns while avoiding false correlations demanded careful statistical approaches.

3. **Balancing privacy and insights**: Designing a system that protects sensitive health data while providing valuable analysis was a key consideration. Thus, fetch was an obvious choice given it's focus on security through the blockchain.

5. **Recommendation relevance**: Generating recommendations that are truly personalized and actionable rather than generic health advice required sophisticated matching algorithms.

## Accomplishments that we're proud of
Despite these challenges, we're proud to have built:

1. A very unique idea that we can see being widely used and an actionable plan to finish up everything not yet completed.

2. Advanced pattern detection algorithms that can identify subtle relationships between daily activities and wellbeing outcomes.

3. A system that transforms raw health data into actionable insights without requiring users to be data scientists themselves.

4. A clean, intuitive user interface that makes complex health analytics accessible and useful.

## What we learned
Throughout this hackathon, our team gained valuable insights into:

- The practical applications of fetch.ai's uAgents for creating sophisticated autonomous systems
- Approaches for identifying meaningful patterns in noisy, real-world health data
- Effective techniques for agent communication and coordination
- The importance of human-centered design when presenting complex health analytics

## What's next for Mood Mentor
Our current implementation demonstrates the core functionality of our vision, but we have ambitious plans for the future:

1. **Integration with fetch.ai's LLM**: The end goal is to leverage fetch.ai's language model to generate even more sophisticated and personalized recommendations based on identified stressors.

2. **Advanced intervention tracking**: Building feedback loops to measure the effectiveness of recommendations and refine them over time.

3. **Community insights**: Creating anonymized, opt-in aggregated insights that help users understand how their stressors and effective interventions compare to similar individuals.

4. **Complete frontend integration**: Fully connecting our backend agent system with the mobile interface to provide seamless, real-time insights and recommendations.

Mood Mentor represents just the beginning of our vision for personalized health intelligence that empowers individuals to understand and improve their wellbeing through the power of autonomous AI agents.

## Built With
- fetch.ai uAgents
- Python
- pandas
- scikit-learn