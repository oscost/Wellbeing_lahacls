"""
Health Analytics System using fetch.ai uAgents

This system analyzes personal health data to identify patterns, detect stressors,
and provide personalized recommendations for improving well-being.

The system consists of three main agents:
1. DataCollectionAgent - Collects and preprocesses health and activity data
2. PatternAnalysisAgent - Identifies correlations and patterns in the data
3. RecommendationAgent - Provides personalized recommendations based on identified stressors

Requirements:
- Python 3.10 or higher
- fetch.ai's uagents package
- pandas for data processing
- scikit-learn for pattern analysis
- matplotlib for data visualization (optional)
"""

import os
import json
import time
import asyncio
from datetime import datetime, timedelta
from typing import Dict, List, Any, Optional

import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans
from collections import Counter

# Import fetch.ai's uAgents framework
from uagents import Agent, Context, Model, Protocol, Bureau

# Define message models for communication between agents
class HealthData(Model):
    """Model for daily health data"""
    user_id: str
    data: List[Dict[str, Any]]
    
class AnalysisRequest(Model):
    """Request for data analysis"""
    user_id: str
    time_period: int

class PatternResult(Model):
    """Results of pattern analysis"""
    user_id: str
    patterns: List[Dict[str, Any]]
    stressors: List[Dict[str, Any]]
    
class RecommendationRequest(Model):
    """Request for personalized recommendations"""
    user_id: str
    stressors: List[Dict[str, Any]]
    
class RecommendationResult(Model):
    """Personalized recommendations"""
    user_id: str
    recommendations: List[Dict[str, Any]]
    
class AnalysisComplete(Model):
    """Notification that analysis is complete"""
    user_id: str
    status: str
    
# Create agents with proper configuration for server endpoints
data_collection_agent = Agent(
    name="data_collection_agent",
    seed="data_collection_seed_phrase",
    port=8000,
    endpoint=["http://0.0.0.0:8000/submit"]
)

pattern_analysis_agent = Agent(
    name="pattern_analysis_agent",
    seed="pattern_analysis_seed_phrase",
    port=8001,
    endpoint=["http://0.0.0.0:8001/submit"]
)

recommendation_agent = Agent(
    name="recommendation_agent",
    seed="recommendation_seed_phrase",
    port=8002,
    endpoint=["http://0.0.0.0:8002/submit"]
)

# Client agent to orchestrate the analysis process
client_agent = Agent(
    name="client_agent",
    seed="client_agent_seed",
    port=8003,
    endpoint=["http://0.0.0.0:8003/submit"]
)

# Create protocols for agent communication
health_analysis_protocol = Protocol("health_analysis")

# Helper functions for data generation and analysis
def generate_mock_health_data(user_id: str, days: int) -> List[Dict]:
    """Generate mock health data for testing purposes"""
    data = []
    base_date = datetime.now() - timedelta(days=days)
    
    # Set up some patterns in the mock data
    # 1. Lower sleep quality correlates with lower mood and energy next day
    # 2. High screen time (>3h) with low productivity correlates with poor sleep
    # 3. Days with >8000 steps correlate with better mood and energy
    
    sleep_quality_pattern = np.sin(np.linspace(0, 3*np.pi, days)) * 2 + 6  # oscillate between 4-8
    screen_time_pattern = np.random.normal(loc=3, scale=1.5, size=days)
    steps_pattern = np.random.normal(loc=7000, scale=3000, size=days)
    
    activities = ["work", "exercise", "leisure", "family", "social", "chores"]
    activity_hours = {activity: 0 for activity in activities}
    
    for i in range(days):
        date = (base_date + timedelta(days=i)).strftime("%Y-%m-%d")
        
        # Generate interrelated values to create patterns
        sleep_quality = max(1, min(10, sleep_quality_pattern[i] + np.random.normal(0, 1)))
        sleep_hours = max(4, min(10, 7 + (sleep_quality - 5) * 0.3 + np.random.normal(0, 0.5)))
        
        screen_time = max(0.5, screen_time_pattern[i])
        # Lower productivity when screen time is high
        screen_productivity = max(0.1, min(1.0, 0.8 - (screen_time - 3) * 0.1 + np.random.normal(0, 0.1)))
        
        steps = max(1000, steps_pattern[i])
        
        # Energy and mood affected by previous day's sleep (if not first day)
        base_energy = 7
        base_mood = 7
        if i > 0:
            prev_sleep_effect = (data[i-1]['sleep_quality'] - 5) * 0.6
            base_energy += prev_sleep_effect
            base_mood += prev_sleep_effect
        
        # Steps improve same-day mood and energy
        steps_effect = (steps - 7000) / 5000
        energy_level = max(1, min(10, round(base_energy + steps_effect + np.random.normal(0, 1))))
        mood_level = max(1, min(10, round(base_mood + steps_effect + np.random.normal(0, 1))))
        
        # Heart rate inversely related to sleep quality and positively to activity
        heart_rate_avg = max(55, min(90, 70 - (sleep_quality - 5) + (steps / 10000 * 10) + np.random.normal(0, 3)))
        
        # Randomize daily activities
        for activity in activities:
            activity_hours[activity] = max(0, min(5, np.random.normal(2, 1)))
        
        # Generate journal entries based on the data
        journal_templates = [
            f"Today was {'an energetic' if energy_level > 7 else 'a low energy'} day. I felt {'great' if mood_level > 7 else 'not so good'}.",
            f"I walked {steps:.0f} steps today and spent {screen_time:.1f} hours on screens.",
            f"Sleep was {'refreshing' if sleep_quality > 7 else 'poor'} last night, got {sleep_hours:.1f} hours.",
            f"My productivity was {'high' if screen_productivity > 0.7 else 'low'} during screen time."
        ]
        daily_journal = " ".join(journal_templates)
        
        # Generate emotional journal
        if mood_level > 7:
            emotional_journal = f"I felt happy and content today. Energy levels were {'high' if energy_level > 7 else 'moderate'}."
        elif mood_level > 4:
            emotional_journal = f"Emotionally neutral day. Nothing particularly exciting or disappointing happened."
        else:
            emotional_journal = f"Feeling down today. {'Low energy and' if energy_level < 5 else ''} Struggling to stay motivated."
        
        # Create the daily record
        daily_data = {
            'date': date,
            'heart_rate_avg': heart_rate_avg,
            'screen_time_hours': screen_time,
            'screen_time_productivity': screen_productivity,
            'steps_walked': int(steps),
            'sleep_hours': sleep_hours,
            'sleep_quality': sleep_quality,
            'energy_level': energy_level,
            'mood_level': mood_level,
            'daily_journal': daily_journal,
            'emotional_journal': emotional_journal,
            'activities': activity_hours.copy()
        }
        
        data.append(daily_data)
    
    return data

def identify_patterns(df: pd.DataFrame) -> List[Dict]:
    """Identify patterns and correlations in the health data"""
    patterns = []
    try:
        # Calculate lagged features for next-day effects
        for col in ['mood_level', 'energy_level', 'sleep_quality']:
            df[f'{col}_next_day'] = df[col].shift(-1)
        
        # Remove the last row which will have NaN for next day values
        df_with_next = df.iloc[:-1].copy()
        
        # 1. Correlation Analysis
        numeric_cols = [
            'heart_rate_avg', 'screen_time_hours', 'screen_time_productivity', 
            'steps_walked', 'sleep_hours', 'sleep_quality', 'energy_level', 
            'mood_level'
        ]
        
        # Add activity columns
        activity_cols = [col for col in df.columns if col.startswith('activity_')]
        numeric_cols.extend(activity_cols)
        
        # Calculate correlation matrix
        correlation_matrix = df_with_next[numeric_cols + ['mood_level_next_day', 'energy_level_next_day', 'sleep_quality_next_day']].corr()
        
        # Significant correlations (absolute value > 0.3)
        for col1 in numeric_cols:
            for col2 in ['mood_level_next_day', 'energy_level_next_day', 'sleep_quality_next_day']:
                corr = correlation_matrix.loc[col1, col2]
                if abs(corr) > 0.3:
                    patterns.append({
                        'type': 'correlation',
                        'factor1': col1,
                        'factor2': col2,
                        'strength': corr,
                        'description': f"{col1.replace('_', ' ')} {'positively' if corr > 0 else 'negatively'} affects {col2.replace('_next_day', ' the next day').replace('_', ' ')} (correlation: {corr:.2f})"
                    })
        
        # 2. Threshold Analysis
        # Check if there are patterns related to specific thresholds
        
        # Screen time > 3 hours effect on sleep
        high_screen_time = df['screen_time_hours'] > 3
        if high_screen_time.sum() > 5:  # Need enough samples
            avg_sleep_after_high_screen = df.loc[high_screen_time, 'sleep_quality'].mean()
            avg_sleep_after_normal_screen = df.loc[~high_screen_time, 'sleep_quality'].mean()
            
            if abs(avg_sleep_after_high_screen - avg_sleep_after_normal_screen) > 0.5:
                patterns.append({
                    'type': 'threshold',
                    'factor': 'screen_time_hours',
                    'threshold': 3,
                    'effect_on': 'sleep_quality',
                    'effect_size': avg_sleep_after_high_screen - avg_sleep_after_normal_screen,
                    'description': f"Sleep quality is {abs(avg_sleep_after_high_screen - avg_sleep_after_normal_screen):.1f} points {'lower' if avg_sleep_after_high_screen < avg_sleep_after_normal_screen else 'higher'} after days with >3 hours of screen time"
                })
        
        # Steps > 8000 effect on mood
        high_steps = df['steps_walked'] > 8000
        if high_steps.sum() > 5:
            avg_mood_high_steps = df.loc[high_steps, 'mood_level'].mean()
            avg_mood_low_steps = df.loc[~high_steps, 'mood_level'].mean()
            
            if abs(avg_mood_high_steps - avg_mood_low_steps) > 0.5:
                patterns.append({
                    'type': 'threshold',
                    'factor': 'steps_walked',
                    'threshold': 8000,
                    'effect_on': 'mood_level',
                    'effect_size': avg_mood_high_steps - avg_mood_low_steps,
                    'description': f"Mood is {abs(avg_mood_high_steps - avg_mood_low_steps):.1f} points {'higher' if avg_mood_high_steps > avg_mood_low_steps else 'lower'} on days with >8000 steps"
                })
        
        # 3. Clustering for identifying typical day patterns
        # Subset of key metrics for clustering
        X = df[['sleep_quality', 'screen_time_hours', 'steps_walked', 'mood_level', 'energy_level']].values
        
        # Standardize the data
        scaler = StandardScaler()
        X_scaled = scaler.fit_transform(X)
        
        # Find optimal number of clusters (simplified)
        k = min(5, len(df) // 5)  # Limit clusters based on data size
        
        # Perform clustering
        kmeans = KMeans(n_clusters=k, random_state=42)
        clusters = kmeans.fit_predict(X_scaled)
        
        # Analyze each cluster
        for i in range(k):
            cluster_days = df[clusters == i]
            if len(cluster_days) >= 3:  # Need at least 3 days in cluster
                cluster_profile = {
                    'sleep_quality': cluster_days['sleep_quality'].mean(),
                    'screen_time': cluster_days['screen_time_hours'].mean(),
                    'steps': cluster_days['steps_walked'].mean(),
                    'mood': cluster_days['mood_level'].mean(),
                    'energy': cluster_days['energy_level'].mean()
                }
                
                # Determine if this is a "good day" or "bad day" cluster
                day_quality = (cluster_profile['mood'] + cluster_profile['energy']) / 2
                
                description = (
                    f"{'Good' if day_quality > 7 else 'Bad' if day_quality < 5 else 'Average'} day pattern: "
                    f"Sleep quality {cluster_profile['sleep_quality']:.1f}/10, "
                    f"{cluster_profile['screen_time']:.1f}h screen time, "
                    f"{cluster_profile['steps']:.0f} steps, "
                    f"Mood {cluster_profile['mood']:.1f}/10, "
                    f"Energy {cluster_profile['energy']:.1f}/10"
                )
                
                patterns.append({
                    'type': 'cluster',
                    'cluster_id': i,
                    'day_quality': 'good' if day_quality > 7 else 'bad' if day_quality < 5 else 'average',
                    'frequency': len(cluster_days),
                    'profile': cluster_profile,
                    'description': description
                })
    except Exception as e:
        print(f"Error in identify_patterns: {e}")
        return []
    
    return patterns

def identify_stressors(df: pd.DataFrame, patterns: List[Dict]) -> List[Dict]:
    """Identify potential stressors based on the patterns"""
    stressors = []
    
    # 1. Extract negative correlations from patterns
    negative_patterns = [p for p in patterns if p['type'] == 'correlation' and p['strength'] < -0.3]
    for pattern in negative_patterns:
        if 'mood' in pattern['factor2'] or 'energy' in pattern['factor2']:
            stressors.append({
                'type': 'correlation_stressor',
                'factor': pattern['factor1'],
                'impact_on': pattern['factor2'].replace('_next_day', ''),
                'strength': abs(pattern['strength']),
                'description': f"{pattern['factor1'].replace('_', ' ')} appears to negatively impact {pattern['factor2'].replace('_next_day', '').replace('_', ' ')}"
            })
    
    # 2. Analyze bad days
    bad_day_clusters = [p for p in patterns if p['type'] == 'cluster' and p['day_quality'] == 'bad']
    for cluster in bad_day_clusters:
        profile = cluster['profile']
        
        # Identify primary factors in bad days
        if profile['sleep_quality'] < 6:
            stressors.append({
                'type': 'factor_stressor',
                'factor': 'poor_sleep',
                'frequency': cluster['frequency'],
                'avg_value': profile['sleep_quality'],
                'description': f"Poor sleep quality (avg. {profile['sleep_quality']:.1f}/10) is associated with bad days"
            })
            
        if profile['screen_time'] > 4:
            stressors.append({
                'type': 'factor_stressor',
                'factor': 'excessive_screen_time',
                'frequency': cluster['frequency'],
                'avg_value': profile['screen_time'],
                'description': f"Excessive screen time (avg. {profile['screen_time']:.1f} hours) is associated with bad days"
            })
            
        if profile['steps'] < 5000:
            stressors.append({
                'type': 'factor_stressor',
                'factor': 'sedentary_behavior',
                'frequency': cluster['frequency'],
                'avg_value': profile['steps'],
                'description': f"Low physical activity (avg. {profile['steps']:.0f} steps) is associated with bad days"
            })
    
    # 3. Analyze journal entries for emotional triggers
    # In a real implementation, we would use NLP here
    # For the mock version, we'll do a simple keyword search
    
    negative_keywords = [
        'stress', 'anxious', 'tired', 'exhausted', 'overwhelmed', 
        'frustrated', 'angry', 'sad', 'depressed', 'worry', 'workload'
    ]
    
    keyword_counts = Counter()
    for journal in df['emotional_journal']:
        for keyword in negative_keywords:
            if keyword in journal.lower():
                keyword_counts[keyword] += 1
    
    # Focus on keywords that appear multiple times
    for keyword, count in keyword_counts.items():
        if count >= max(2, len(df) * 0.1):  # At least 2 occurrences or 10% of days
            stressors.append({
                'type': 'emotional_stressor',
                'factor': keyword,
                'frequency': count,
                'description': f"'{keyword}' mentioned in {count} journal entries"
            })
    
    # 4. Look at low productivity screen time
    if (df['screen_time_productivity'] < 0.5).sum() > max(3, len(df) * 0.2):
        avg_unproductive_screen_time = df.loc[df['screen_time_productivity'] < 0.5, 'screen_time_hours'].mean()
        stressors.append({
            'type': 'productivity_stressor',
            'factor': 'unproductive_screen_time',
            'avg_hours': avg_unproductive_screen_time,
            'description': f"Unproductive screen time averaging {avg_unproductive_screen_time:.1f} hours on low-productivity days"
        })
    
    # Merge similar stressors
    merged_stressors = []
    added_factors = set()
    
    for stressor in stressors:
        if stressor['factor'] not in added_factors:
            similar = [s for s in stressors if s['factor'] == stressor['factor']]
            if len(similar) > 1:
                # Take the one with highest strength/frequency
                best_match = max(similar, key=lambda s: s.get('strength', 0) if 'strength' in s else s.get('frequency', 0))
                merged_stressors.append(best_match)
            else:
                merged_stressors.append(stressor)
            added_factors.add(stressor['factor'])
    
    return merged_stressors

def generate_recommendations(stressors: List[Dict]) -> List[Dict]:
    """Generate personalized recommendations based on identified stressors"""
    recommendations = []
    
    # Process each stressor and generate tailored recommendations
    for stressor in stressors:
        factor = stressor.get('factor', '')
        
        # Generate stressor-specific recommendations
        if 'poor_sleep' in factor:
            recommendations.extend([
                {
                    'stressor': factor,
                    'recommendation': 'Establish a consistent sleep schedule, going to bed and waking up at the same time each day',
                    'evidence': 'Research shows consistent sleep schedules help regulate circadian rhythm',
                    'impact': 'Could improve sleep quality by 15-20%'
                },
                {
                    'stressor': factor,
                    'recommendation': 'Create a relaxing pre-sleep routine (reading, light stretching, no screens 1 hour before bed)',
                    'evidence': 'Blue light from screens can suppress melatonin production',
                    'impact': 'Can reduce sleep onset time by 15-30 minutes'
                }
            ])
            
        elif 'screen_time' in factor:
            recommendations.extend([
                {
                    'stressor': factor,
                    'recommendation': 'Schedule 2-hour blocks of focused work with 15-minute screen breaks',
                    'evidence': 'Regular breaks improve overall productivity and reduce eye strain',
                    'impact': 'Can improve productivity by 20% while reducing overall screen time'
                },
                {
                    'stressor': factor,
                    'recommendation': 'Use app blockers to limit social media use to specific times of day',
                    'evidence': 'Context switching between work and social media reduces cognitive performance',
                    'impact': 'Can reduce unproductive screen time by 40%'
                }
            ])
            
        elif 'sedentary' in factor or factor == 'steps_walked':
            recommendations.extend([
                {
                    'stressor': factor,
                    'recommendation': 'Set a timer to stand up and walk for 5 minutes every hour',
                    'evidence': 'Even short activity breaks can improve metabolism and energy levels',
                    'impact': 'Can add 1000-2000 steps to your daily count'
                },
                {
                    'stressor': factor,
                    'recommendation': 'Schedule 20-30 minute walks after lunch and dinner',
                    'evidence': 'Post-meal walks help with digestion and blood sugar regulation',
                    'impact': 'Can improve mood scores by 1-2 points on walking days'
                }
            ])
            
        elif 'unproductive_screen_time' in factor:
            recommendations.extend([
                {
                    'stressor': factor,
                    'recommendation': 'Use the Pomodoro technique: 25 minutes of focused work followed by a 5-minute break',
                    'evidence': 'Structured work intervals improve focus and reduce procrastination',
                    'impact': 'Can increase productive screen time by 30%'
                }
            ])
            
        elif any(k in factor for k in ['stress', 'anxious', 'overwhelm', 'tired', 'exhausted']):
            recommendations.extend([
                {
                    'stressor': factor,
                    'recommendation': 'Practice 10 minutes of mindfulness meditation daily',
                    'evidence': 'Regular meditation reduces cortisol levels and improves stress resilience',
                    'impact': 'Can reduce stress levels by 25% within 8 weeks of consistent practice'
                },
                {
                    'stressor': factor,
                    'recommendation': 'Schedule worry time: 15 minutes to write down all concerns, then set them aside',
                    'evidence': 'Containing worry to a specific time reduces rumination throughout the day',
                    'impact': 'Can improve focus and reduce anxiety-related thought patterns'
                }
            ])
    
    # Add general wellbeing recommendations
    general_recommendations = [
        {
            'stressor': 'general_wellbeing',
            'recommendation': 'Drink water immediately upon waking and aim for 2-3 liters throughout the day',
            'evidence': 'Proper hydration improves cognition, energy, and metabolic function',
            'impact': 'Can increase energy levels by 10-15%'
        },
        {
            'stressor': 'general_wellbeing',
            'recommendation': 'Spend 15 minutes outside in natural light within 1 hour of waking',
            'evidence': 'Morning light exposure regulates circadian rhythm and boosts vitamin D',
            'impact': 'Can improve mood and sleep quality by regulating melatonin production'
        }
    ]
    
    # Add general recommendations only if we don't have too many specific ones
    if len(recommendations) < 5:
        recommendations.extend(general_recommendations)
    
    # Prioritize recommendations (in a real system, would be based on user preferences and history)
    # For demo purposes, we'll limit to top 5, prioritizing specific ones over general
    specific_recommendations = [r for r in recommendations if r['stressor'] != 'general_wellbeing']
    general_recommendations = [r for r in recommendations if r['stressor'] == 'general_wellbeing']
    
    prioritized_recommendations = specific_recommendations[:4]
    if len(prioritized_recommendations) < 5:
        prioritized_recommendations.extend(general_recommendations[:5-len(prioritized_recommendations)])
    
    return prioritized_recommendations

# Setup the Data Collection Agent
@data_collection_agent.on_event("startup")
async def data_collection_startup(ctx: Context):
    """Initialize the agent"""
    ctx.logger.info(f"Data Collection Agent started with address: {data_collection_agent.address}")
    await ctx.storage.set("initialized", "true")

@data_collection_agent.on_message(model=AnalysisRequest)
async def handle_analysis_request(ctx: Context, sender: str, msg: AnalysisRequest):
    """Handle requests for user health data"""
    ctx.logger.info(f"Received analysis request for user: {msg.user_id}, period: {msg.time_period} days")
    
    # Generate or fetch real data
    health_data = generate_mock_health_data(msg.user_id, msg.time_period)
    
    # Store the data
    await ctx.storage.set(f"health_data_{msg.user_id}", json.dumps(health_data))
    
    # Send the data to the pattern analysis agent
    await ctx.send(
        pattern_analysis_agent.address,
        HealthData(user_id=msg.user_id, data=health_data)
    )
    
    ctx.logger.info(f"Sent health data for user {msg.user_id} to pattern analysis agent")

# Setup the Pattern Analysis Agent
@pattern_analysis_agent.on_event("startup")
async def pattern_analysis_startup(ctx: Context):
    """Initialize the agent"""
    ctx.logger.info(f"Pattern Analysis Agent started with address: {pattern_analysis_agent.address}")
    await ctx.storage.set("initialized", "true")

@pattern_analysis_agent.on_message(model=HealthData)
async def analyze_patterns(ctx: Context, sender: str, msg: HealthData):
    """Analyze patterns in user health data"""
    ctx.logger.info(f"Analyzing patterns for user: {msg.user_id}")
    
    # Convert to DataFrame for analysis
    df = pd.DataFrame(msg.data)
    
    # Extract activity data into separate columns
    for activity in msg.data[0]['activities'].keys():
        df[f'activity_{activity}'] = df['activities'].apply(lambda x: x.get(activity, 0))
    
    # Perform pattern analysis
    patterns = identify_patterns(df)
    
    # Identify stressors
    stressors = identify_stressors(df, patterns)
    
    # Store the results
    analysis_result = {
        'patterns': patterns,
        'stressors': stressors
    }
    await ctx.storage.set(f"analysis_result_{msg.user_id}", json.dumps(analysis_result))
    
    # Send stressors to recommendation agent
    await ctx.send(
        recommendation_agent.address,
        RecommendationRequest(user_id=msg.user_id, stressors=stressors)
    )
    
    ctx.logger.info(f"Completed pattern analysis for user {msg.user_id} and sent to recommendation agent")

# Setup the Recommendation Agent
@recommendation_agent.on_event("startup")
async def recommendation_startup(ctx: Context):
    """Initialize the agent"""
    ctx.logger.info(f"Recommendation Agent started with address: {recommendation_agent.address}")
    await ctx.storage.set("initialized", "true")

@recommendation_agent.on_message(model=RecommendationRequest)
async def generate_recommendations_handler(ctx: Context, sender: str, msg: RecommendationRequest):
    """Generate personalized recommendations based on identified stressors"""
    ctx.logger.info(f"Generating recommendations for user: {msg.user_id}")
    
    # Generate recommendations
    recommendations = generate_recommendations(msg.stressors)
    
    # Store the recommendations
    await ctx.storage.set(f"recommendations_{msg.user_id}", json.dumps(recommendations))
    
    # Send completion notification
    await ctx.send(
        client_agent.address,  
        AnalysisComplete(user_id=msg.user_id, status="completed")
    )
    
    ctx.logger.info(f"Generated {len(recommendations)} recommendations for user {msg.user_id}")

# Setup the Client Agent
@client_agent.on_event("startup")
async def client_startup(ctx: Context):
    """Initialize the client agent"""
    ctx.logger.info(f"Client Agent started with address: {client_agent.address}")
    await ctx.storage.set("initialized", "true")

@client_agent.on_message(model=AnalysisComplete)
async def handle_analysis_complete(ctx: Context, sender: str, msg: AnalysisComplete):
    """Handle notification that analysis is complete"""
    ctx.logger.info(f"Analysis completed for user: {msg.user_id}")
    
    # Retrieve pattern analysis results
    pattern_analysis_json = await pattern_analysis_agent.storage.get(f"analysis_result_{msg.user_id}")
    if pattern_analysis_json:
        pattern_analysis_result = json.loads(pattern_analysis_json)
    else:
        pattern_analysis_result = {"patterns": [], "stressors": []}
    
    # Retrieve recommendations
    recommendations_json = await recommendation_agent.storage.get(f"recommendations_{msg.user_id}")
    if recommendations_json:
        recommendations_result = json.loads(recommendations_json)
    else:
        recommendations_result = []
    
    # Combine results
    full_result = {
        'user_id': msg.user_id,
        'analysis_date': datetime.now().strftime("%Y-%m-%d"),
        'patterns': pattern_analysis_result.get('patterns', []),
        'stressors': pattern_analysis_result.get('stressors', []),
        'recommendations': recommendations_result
    }
    
    # Store the result for retrieval
    await ctx.storage.set(f"analysis_results_{msg.user_id}", json.dumps(full_result))
    
    ctx.logger.info(f"Retrieved and stored full analysis for user {msg.user_id}")

# Function to start the analysis process
async def start_analysis(user_id: str, days: int = 30) -> Dict:
    """Start the health data analysis process for a user"""
    try:
        # We need a context to send messages, which we don't have outside handlers
        # Instead, we'll use a direct approach with a manually created analysis result
        
        # Generate mock data directly
        health_data = generate_mock_health_data(user_id, days)
        
        # Process directly without agent communication
        df = pd.DataFrame(health_data)
        
        # Extract activity data
        for activity in health_data[0]['activities'].keys():
            df[f'activity_{activity}'] = df['activities'].apply(lambda x: x.get(activity, 0))
        
        # Analyze patterns
        patterns = identify_patterns(df)
        
        # Identify stressors
        stressors = identify_stressors(df, patterns)
        
        # Generate recommendations
        recommendations = generate_recommendations(stressors)
        
        # Create result
        result = {
            'user_id': user_id,
            'analysis_date': datetime.now().strftime("%Y-%m-%d"),
            'patterns': patterns,
            'stressors': stressors,
            'recommendations': recommendations
        }
        
        return result
    except Exception as e:
        print(f"Error in start_analysis: {e}")
        return {
            'user_id': user_id,
            'error': f'Error during analysis: {str(e)}',
            'analysis_date': datetime.now().strftime("%Y-%m-%d")
        }

# Create a Bureau to manage all agents
bureau = Bureau()
bureau.add(client_agent)
bureau.add(data_collection_agent)
bureau.add(pattern_analysis_agent) 
bureau.add(recommendation_agent)

# Main function to run the system
# Main function to run the system
async def main():
    """Run the health analytics system"""

    # Start all agents individually rather than using Bureau.run()
    tasks = []
    tasks.append(asyncio.create_task(client_agent.run_async()))
    tasks.append(asyncio.create_task(data_collection_agent.run_async()))
    tasks.append(asyncio.create_task(pattern_analysis_agent.run_async()))
    tasks.append(asyncio.create_task(recommendation_agent.run_async()))
    
    # Give agents time to start up
    await asyncio.sleep(5)
    
    # Start the analysis process
    result = await start_analysis("user123", 30)
    
    # Print results
    print("\n--- HEALTH ANALYTICS REPORT ---")
    print(f"User: {result['user_id']}")
    print(f"Analysis Date: {result['analysis_date']}")
    
    if 'error' in result:
        print(f"\nError: {result['error']}")
    else:
        print("\n--- KEY PATTERNS IDENTIFIED ---")
        if 'patterns' in result:
            for pattern in result['patterns']:
                print(f"- {pattern['description']}")
        else:
            print("No patterns identified or analysis failed")
        
        print("\n--- PRIMARY STRESSORS ---")
        if 'stressors' in result:
            for stressor in result['stressors']:
                print(f"- {stressor['description']}")
        else:
            print("No stressors identified or analysis failed")
        
        print("\n--- PERSONALIZED RECOMMENDATIONS ---")
        if 'recommendations' in result:
            for rec in result['recommendations']:
                print(f"- {rec['recommendation']}")
                print(f"  Evidence: {rec['evidence']}")
                print(f"  Potential Impact: {rec['impact']}")
                print()
        else:
            print("No recommendations generated or analysis failed")
    
    # Improved shutdown with proper error handling
    for task in tasks:
        task.cancel()
        try:
            # Allow each task a short time to close gracefully
            await asyncio.wait_for(asyncio.shield(task), timeout=0.5)
        except asyncio.TimeoutError:
            # Task didn't finish in time, but we're shutting down anyway
            pass
        except asyncio.CancelledError:
            # Task was cancelled successfully
            pass
        except Exception as e:
            # Log any other errors but continue shutdown
            print(f"Warning during task cancellation: {e}")
    
    # # Ensure we cleanup any pending tasks
    # remaining_tasks = [t for t in asyncio.all_tasks() if t is not asyncio.current_task()]
    # if remaining_tasks:
    #     print(f"Cleaning up {len(remaining_tasks)} remaining tasks...")
    #     # Give remaining tasks a final chance to complete
    #     await asyncio.gather(*remaining_tasks, return_exceptions=True)

# Run the main function
if __name__ == "__main__":
    asyncio.run(main())