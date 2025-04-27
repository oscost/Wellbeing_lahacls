# Health Analytics System using fetch.ai uAgents

This system uses fetch.ai's uAgents framework to create a personalized health analytics platform that:
1. Collects and analyzes comprehensive health data
2. Identifies patterns and correlations between activities and health outcomes
3. Detects personal stressors affecting wellbeing
4. Provides personalized, evidence-based recommendations

## Architecture

The system is built using a multi-agent architecture with four specialized autonomous agents:

1. **Data Collection Agent** - Integrates and standardizes inputs from various sources:
   - Wearable device data (heart rate, steps, sleep)
   - Screen time tracking applications
   - Journal entries for activities and emotional state
   - User-provided ratings for energy and mood

2. **Pattern Analysis Agent** - Processes the data to uncover patterns:
   - Time-series analysis to identify correlations
   - Threshold detection to find critical trigger points
   - Clustering to determine "good day" vs "bad day" patterns
   - NLP processing of journal entries to extract sentiment and topics
   - Detection of lag effects (e.g., impact of activities on next-day metrics)

3. **Recommendation Agent** - Provides personalized suggestions:
   - Matches identified stressors with evidence-based interventions
   - Prioritizes recommendations based on correlation strength
   - Generates specific, actionable, personalized suggestions

4. **Client Agent** - Orchestrates the workflow and communication:
   - Initiates the analysis process
   - Collects results from the other agents
   - Provides the unified analysis to the user

## Requirements

- Python 3.10 or higher
- fetch.ai's uAgents package
- pandas for data processing
- scikit-learn for pattern analysis
- matplotlib for visualization (optional)

## Installation

```bash
pip install uagents pandas scikit-learn matplotlib
```

## Usage

1. **Run the agents:**

```python
import asyncio
from health_analytics import main

# Run the main function which starts all agents and performs analysis
if __name__ == "__main__":
    asyncio.run(main())
```

2. **Customize for your own data:**

Modify the `generate_mock_health_data` function to connect with your real data sources. In a production environment, you would replace this with API calls to your existing data collection systems.

## How It Works with fetch.ai

The system leverages fetch.ai's uAgents framework to create autonomous agents that can:

1. **Communicate securely** - Agents use the fetch.ai messaging protocol to exchange data.
2. **Store data** - Each agent maintains its own storage for relevant data.
3. **Execute on schedule** - Agents can perform tasks on intervals or in response to messages.
4. **Operate autonomously** - Each agent has its specific role and can work independently.
5. **Scale across devices** - In a production deployment, agents can run on different devices or servers.

The fetch.ai uAgents are defined with their own addresses which allows them to be discovered and communicate in a secure, decentralized manner.

## Example Output

The system produces a comprehensive analysis with three main components:

### 1. Identified Patterns

```
- Sleep quality is 1.2 points lower after days with >3 hours of screen time
- Mood is 1.8 points higher on days with >8000 steps
- Screen time productivity appears to negatively impact energy level the next day
```

### 2. Primary Stressors

```
- Excessive screen time (avg. 4.2 hours) is associated with bad days
- Poor sleep quality (avg. 5.1/10) is associated with bad days
- 'stress' mentioned in 7 journal entries
```

### 3. Personalized Recommendations

```
- Schedule 2-hour blocks of focused work with 15-minute screen breaks
  Evidence: Regular breaks improve overall productivity and reduce eye strain
  Potential Impact: Can improve productivity by 20% while reducing overall screen time

- Establish a consistent sleep schedule, going to bed and waking up at the same time each day
  Evidence: Research shows consistent sleep schedules help regulate circadian rhythm
  Potential Impact: Could improve sleep quality by 15-20%
  
- Set a timer to stand up and walk for 5 minutes every hour
  Evidence: Even short activity breaks can improve metabolism and energy levels
  Potential Impact: Can add 1000-2000 steps to your daily count
```

## Customization and Extension

### Adding New Data Sources

To add a new data source:

1. Modify the `HealthData` model to include the new data fields
2. Update the data collection agent to process the new data
3. Add pattern recognition for the new data in the pattern analysis agent

### Adding New Recommendation Types

To add new recommendation categories:

1. Identify new stressor types in the `identify_stressors` function
2. Add new recommendation templates in the `generate_recommendations` function

### Deploying to Agentverse

For a production deployment on fetch.ai's Agentverse:

1. Register your agents on the fetch.ai Almanac
2. Deploy them to the Agentverse platform
3. Configure the appropriate permissions and endpoints

## Production Deployment

For a production deployment:

1. Replace the mock data generation with real API integrations for wearables and apps
2. Add proper authentication and user management
3. Deploy the agents to fetch.ai's Agentverse for continuous operation
4. Add a web or mobile UI for users to interact with the system
5. Implement proper error handling and recovery mechanisms

## License

This project is licensed under the MIT License - see the LICENSE file for details.