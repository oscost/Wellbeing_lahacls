# fetch_agents.py
"""
Simplified implementation of Fetch.ai agents for health data analysis
"""
import pandas as pd
import numpy as np
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler
import uuid
from datetime import datetime

class FetchAgentSystem:
    """
    A simplified implementation of a Fetch.ai agent system for hackathon purposes.
    This mimics the functionality of a full Fetch.ai uAgent system without requiring
    the complete uAgents framework setup.
    """
    
    def __init__(self):
        self.session_id = str(uuid.uuid4())
        print(f"Agent system initialized with session ID: {self.session_id}")
    
    async def analyze_data(self, entries):
        """
        Analyze wellbeing data using AI techniques that would be part of a Fetch.ai system
        """
        # Convert entries list to a DataFrame
        df = pd.DataFrame(entries)
        
        # Convert date strings to datetime if needed
        if 'date' in df.columns and isinstance(df['date'].iloc[0], str):
            df['date'] = pd.to_datetime(df['date'])
        
        # Analysis pipeline
        physical_insights = self._analyze_physical_data(df)
        emotional_insights = self._analyze_emotional_data(df)
        correlations = self._find_correlations(df, physical_insights, emotional_insights)
        stressors = self._identify_stressors(df, correlations)
        recommendations = self._generate_recommendations(stressors, df)
        
        return {
            "session_id": self.session_id,
            "analysis_timestamp": datetime.now().isoformat(),
            "stressors": stressors,
            "recommendations": recommendations,
            "insights": {
                "physical": physical_insights,
                "emotional": emotional_insights,
                "correlations": correlations
            }
        }
    
    def _analyze_physical_data(self, df):
        """Physical metrics analysis - similar to what a physical agent would do"""
        insights = {}
        
        # Analyze sleep patterns if data available
        if 'sleepHours' in df.columns:
            avg_sleep = df['sleepHours'].mean()
            sleep_std = df['sleepHours'].std()
            sleep_deficit = avg_sleep < 7.0
            
            insights["sleep"] = {
                "average": round(avg_sleep, 2),
                "consistency": round(100 * (1 - min(1, sleep_std / 2)), 2),  # Higher is more consistent
                "deficit": sleep_deficit,
                "minimum": round(df['sleepHours'].min(), 2),
                "maximum": round(df['sleepHours'].max(), 2)
            }
        
        # Analyze activity patterns if data available
        required_columns = ['steps', 'heartRate', 'sleepHours']
        if all(col in df.columns for col in required_columns):
            try:
                # Extract features
                features = df[required_columns].values
                
                # Normalize features
                scaler = StandardScaler()
                normalized_features = scaler.fit_transform(features)
                
                # Cluster using K-means
                kmeans = KMeans(n_clusters=3, random_state=0, n_init=10).fit(normalized_features)
                
                # Get cluster centers in original scale
                cluster_centers = scaler.inverse_transform(kmeans.cluster_centers_)
                
                # Identify which cluster is which activity level based on steps
                center_steps = [center[0] for center in cluster_centers]
                sorted_indices = np.argsort(center_steps)
                
                # Get cluster frequencies
                cluster_counts = np.bincount(kmeans.labels_)
                cluster_percentages = (cluster_counts / len(df)) * 100
                
                insights["activity_patterns"] = {
                    "low_activity_days": round(cluster_percentages[sorted_indices[0]], 2),
                    "moderate_activity_days": round(cluster_percentages[sorted_indices[1]], 2),
                    "high_activity_days": round(cluster_percentages[sorted_indices[2]], 2),
                    "clusters": {
                        "low": {
                            "steps": int(cluster_centers[sorted_indices[0]][0]),
                            "heartRate": int(cluster_centers[sorted_indices[0]][1]),
                            "sleepHours": round(cluster_centers[sorted_indices[0]][2], 2)
                        },
                        "moderate": {
                            "steps": int(cluster_centers[sorted_indices[1]][0]),
                            "heartRate": int(cluster_centers[sorted_indices[1]][1]),
                            "sleepHours": round(cluster_centers[sorted_indices[1]][2], 2)
                        },
                        "high": {
                            "steps": int(cluster_centers[sorted_indices[2]][0]),
                            "heartRate": int(cluster_centers[sorted_indices[2]][1]),
                            "sleepHours": round(cluster_centers[sorted_indices[2]][2], 2)
                        }
                    }
                }
            except Exception as e:
                print(f"Error in activity pattern analysis: {str(e)}")
        
        # Analyze screen time if available
        if 'screenTimeMinutes' in df.columns:
            avg_screen = df['screenTimeMinutes'].mean()
            excessive_screen = avg_screen > 180  # More than 3 hours
            
            insights["screen_time"] = {
                "average_minutes": round(avg_screen, 2),
                "excessive": excessive_screen,
                "recommended_limit_minutes": 180
            }
        
        return insights
    
    def _analyze_emotional_data(self, df):
        """Emotional data analysis - similar to what an emotional agent would do"""
        insights = {}
        
        # Analyze mood patterns if available
        if 'mood' in df.columns:
            avg_mood = df['mood'].mean()
            mood_std = df['mood'].std()
            
            # Determine mood trend if enough data points
            mood_trend = "stable"
            if len(df) >= 3:
                # Simple linear regression for trend
                x = np.arange(len(df))
                y = df['mood'].values
                slope = np.polyfit(x, y, 1)[0]
                
                if slope > 0.1:
                    mood_trend = "improving"
                elif slope < -0.1:
                    mood_trend = "declining"
            
            insights["mood_patterns"] = {
                "average": round(avg_mood, 2),
                "volatility": round(mood_std, 2),
                "trend": mood_trend
            }
        
        # Analyze energy levels if available
        if 'energy' in df.columns:
            avg_energy = df['energy'].mean()
            energy_std = df['energy'].std()
            
            insights["energy_patterns"] = {
                "average": round(avg_energy, 2),
                "volatility": round(energy_std, 2)
            }
        
        # Simple text analysis of emotional descriptions if available
        if 'emotionalState' in df.columns or 'dailyJournal' in df.columns:
            # Combine available text fields
            text_fields = []
            if 'emotionalState' in df.columns:
                text_fields.append(df['emotionalState'].fillna(''))
            if 'dailyJournal' in df.columns:
                text_fields.append(df['dailyJournal'].fillna(''))
                
            combined_text = ' '.join([' '.join(fields) for fields in zip(*text_fields)])
            
            # Basic sentiment analysis using predefined keywords
            emotions = {
                "positive": ["happy", "joy", "excited", "great", "good", "wonderful", "pleased", "calm"],
                "negative": ["sad", "unhappy", "depressed", "upset", "down", "angry", "mad", "frustrated", 
                             "anxious", "worried", "stressed", "overwhelmed"]
            }
            
            # Count occurrences
            sentiment_counts = {sentiment: 0 for sentiment in emotions}
            
            for sentiment, keywords in emotions.items():
                for keyword in keywords:
                    sentiment_counts[sentiment] += combined_text.lower().count(keyword)
            
            # Calculate sentiment ratio
            total_mentions = sum(sentiment_counts.values())
            if total_mentions > 0:
                positive_ratio = sentiment_counts["positive"] / total_mentions
                sentiment = "positive" if positive_ratio > 0.6 else "negative" if positive_ratio < 0.4 else "mixed"
            else:
                sentiment = "neutral"
                positive_ratio = 0.5
            
            insights["sentiment"] = {
                "overall": sentiment,
                "positive_ratio": round(positive_ratio * 100, 2),
                "negative_ratio": round((1 - positive_ratio) * 100, 2)
            }
            
            # Simple stress keyword analysis
            stress_keywords = ["stress", "stressed", "pressure", "overwhelmed", "burnout", 
                              "exhausted", "tired", "deadline", "workload", "worried", "anxiety"]
            
            stress_mentions = sum(combined_text.lower().count(keyword) for keyword in stress_keywords)
            
            insights["stress_indicators"] = {
                "mentions": stress_mentions,
                "word_count": len(combined_text.split()),
                "stress_score": round(min(10, stress_mentions * 2), 2) if combined_text else 0  # Scale from 0-10
            }
        
        return insights
    
    def _find_correlations(self, df, physical_insights, emotional_insights):
        """Find correlations between different metrics"""
        correlations = {}
        
        # Check if we have both mood and other metrics to correlate
        correlation_columns = ['mood', 'energy', 'steps', 'heartRate', 'sleepHours', 'screenTimeMinutes']
        available_columns = [col for col in correlation_columns if col in df.columns]
        
        if 'mood' in available_columns and len(available_columns) > 1:
            # Calculate correlations
            corr_matrix = df[available_columns].corr()
            
            # Get correlations with mood
            mood_correlations = corr_matrix['mood'].drop('mood')
            
            # Find significant correlations
            significant_correlations = []
            for metric, value in mood_correlations.items():
                if abs(value) >= 0.3:  # Threshold for meaningful correlation
                    relationship = "positive" if value > 0 else "negative"
                    impact = "strong" if abs(value) > 0.7 else "moderate" if abs(value) > 0.5 else "weak"
                    
                    significant_correlations.append({
                        "metric": metric,
                        "correlation": round(float(value), 2),
                        "relationship": relationship,
                        "impact": impact
                    })
            
            correlations["mood_factors"] = significant_correlations
        
        return correlations
    
    def _identify_stressors(self, df, correlations):
        """Identify potential stressors based on the data analysis"""
        stressors = []
        
        # Check sleep-related stressors
        if 'sleepHours' in df.columns:
            avg_sleep = df['sleepHours'].mean()
            if avg_sleep < 7.0:
                stressor_level = min(10, int(10 - avg_sleep))
                stressors.append({
                    "name": "Sleep Deficit",
                    "level": stressor_level,
                    "description": f"Your average sleep of {avg_sleep:.1f} hours is below the recommended 7-9 hours",
                    "impact": "High sleep deficit can affect mood, cognitive function, and physical health"
                })
        
        # Check screen time stressors
        if 'screenTimeMinutes' in df.columns:
            avg_screen = df['screenTimeMinutes'].mean()
            if avg_screen > 180:  # More than 3 hours
                screen_hours = avg_screen / 60
                stressor_level = min(10, int(screen_hours))
                stressors.append({
                    "name": "Digital Overload",
                    "level": stressor_level,
                    "description": f"Your average screen time of {screen_hours:.1f} hours may be impacting your wellbeing",
                    "impact": "Excessive screen time can contribute to eye strain, sleep issues, and reduced physical activity"
                })
        
        # Check mood-related stressors
        if 'mood' in df.columns:
            avg_mood = df['mood'].mean()
            if avg_mood < 5.0:
                mood_level = 11 - int(avg_mood)  # Convert to 1-10 scale
                stressors.append({
                    "name": "Low Mood Patterns",
                    "level": mood_level,
                    "description": f"Your mood ratings average {avg_mood:.1f}/10, suggesting potential emotional challenges",
                    "impact": "Persistent low mood can affect overall wellbeing and daily functioning"
                })
        
        # Check for potential physical activity stressors
        if 'steps' in df.columns:
            avg_steps = df['steps'].mean()
            if avg_steps < 5000:
                activity_level = min(10, int(10 - (avg_steps / 1000)))
                stressors.append({
                    "name": "Low Physical Activity",
                    "level": activity_level,
                    "description": f"Your average of {avg_steps:.0f} steps is below the recommended 7,000-10,000 steps",
                    "impact": "Insufficient physical activity can negatively impact mood, energy levels, and overall health"
                })
        
        # Use correlations to identify additional stressors
        if correlations and "mood_factors" in correlations:
            for factor in correlations["mood_factors"]:
                # Only consider negative correlations as potential stressors
                if factor["relationship"] == "negative" and factor["impact"] in ["moderate", "strong"]:
                    metric = factor["metric"]
                    correlation = factor["correlation"]
                    
                    # Create a stressor based on the correlated metric
                    if metric == "screenTimeMinutes" and not any(s["name"] == "Digital Overload" for s in stressors):
                        stressors.append({
                            "name": "Screen Time Impact",
                            "level": min(10, int(abs(correlation) * 10)),
                            "description": "Screen time appears to be negatively affecting your mood",
                            "impact": "Your data shows that higher screen time correlates with lower mood scores"
                        })
                    elif metric == "sleepHours" and not any(s["name"] == "Sleep Deficit" for s in stressors):
                        stressors.append({
                            "name": "Sleep Quality Impact",
                            "level": min(10, int(abs(correlation) * 10)),
                            "description": "Sleep patterns appear to be significantly affecting your mood",
                            "impact": "Your data shows that sleep hours correlate strongly with mood changes"
                        })
        
        return stressors
    
    def _generate_recommendations(self, stressors, df):
        """Generate personalized recommendations based on identified stressors"""
        recommendations = []
        
        for stressor in stressors:
            name = stressor["name"]
            level = stressor["level"]
            
            # Sleep-related recommendations
            if "Sleep" in name:
                recommendations.append({
                    "target": "Sleep Optimization",
                    "recommendation": "Improve sleep quality and duration",
                    "priority": "high" if level >= 7 else "medium",
                    "actions": [
                        "Establish a consistent sleep schedule, going to bed and waking up at the same time daily",
                        "Create a relaxing bedtime routine (reading, gentle stretching, warm bath)",
                        "Limit screen time at least 1 hour before bed",
                        "Ensure your bedroom is dark, quiet, and cool",
                        "Consider using a sleep tracking app for more detailed insights"
                    ]
                })
            
            # Screen time recommendations
            elif "Digital" in name or "Screen" in name:
                recommendations.append({
                    "target": "Digital Wellbeing",
                    "recommendation": "Reduce screen time and improve digital habits",
                    "priority": "high" if level >= 7 else "medium",
                    "actions": [
                        "Set specific times to check emails and social media",
                        "Use 'Do Not Disturb' mode during focus time and before bed",
                        "Take regular breaks using the 20-20-20 rule (every 20 minutes, look at something 20 feet away for 20 seconds)",
                        "Designate screen-free times or zones in your home",
                        "Use screen time tracking apps to set limits on device usage"
                    ]
                })
            
            # Mood-related recommendations
            elif "Mood" in name:
                recommendations.append({
                    "target": "Mood Enhancement",
                    "recommendation": "Implement strategies to improve emotional wellbeing",
                    "priority": "high" if level >= 7 else "medium",
                    "actions": [
                        "Schedule small moments of joy throughout your day",
                        "Practice gratitude by noting three positive things daily",
                        "Spend time in nature - even a short walk in a park can boost mood",
                        "Reach out to supportive friends or family regularly",
                        "Consider mindfulness or meditation practices to manage stress"
                    ]
                })
            
            # Physical activity recommendations
            elif "Activity" in name or "steps" in name.lower():
                # Calculate current average
                current_avg = df['steps'].mean() if 'steps' in df.columns else 3000
                # Set a realistic target
                target = min(int(current_avg * 1.2), 10000)  # 20% increase or 10,000 max
                
                recommendations.append({
                    "target": "Physical Activity",
                    "recommendation": f"Gradually increase daily activity",
                    "priority": "high" if level >= 7 else "medium",
                    "actions": [
                        f"Set a goal of {target} steps daily",
                        "Break up long sitting periods with short walks",
                        "Schedule 10-minute movement breaks throughout your day",
                        "Find physical activities you enjoy to make movement sustainable",
                        "Consider tracking progress with a fitness app or device"
                    ]
                })
        
        # Add general wellbeing recommendation if we have limited stressors
        if len(recommendations) < 2:
            recommendations.append({
                "target": "General Wellbeing",
                "recommendation": "Incorporate balanced wellbeing practices",
                "priority": "medium",
                "actions": [
                    "Maintain a consistent daily routine",
                    "Stay hydrated and eat nutritious meals",
                    "Take short breaks throughout the day to reset",
                    "Practice deep breathing or meditation when feeling stressed",
                    "Balance work with activities you enjoy"
                ]
            })
        
        return recommendations