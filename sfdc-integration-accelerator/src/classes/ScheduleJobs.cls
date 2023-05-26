/**
 * @description: This utility class is used to schedule jobs.
 * @usage: Create a new instance of this class and call the methods you need.
 * @tip: Apex Jobs are constructed with this syntax: Seconds Minutes Hours Day_of_month Month Day_of_week Optional_year
 * @author: Henrique Bustillos - Everymind
 */
public class ScheduleJobs {

    public static Integer jobCountForTest = 0;

    public void intoMinutesInterval ( Schedulable service,  Integer minuteInterval ) {

        String cronExpression = ' * * * ?';
        Integer i = 0;
        String executionMinute = '';

        while ( i < 60 ) {

            if (i < 10) executionMinute = '0';

            executionMinute += i;

            System.schedule( getServiceName(service) + '  ' + jobCountForTest + ' ' + executionMinute , '0 ' + executionMinute + cronExpression , service );

            i += minuteInterval;

            executionMinute = '';
        }
    }

    /*
     * @description: Start the job with a specific day of the week and hour
     * @param dayOfWeek: String with the day of the week (MON, TUE, WED, THU, FRI, SAT, SUN)
     * @param hour: Integer with the hour of the day (0-23)
     */
    public void weekly ( Schedulable service, DayOfWeek dayOfWeek, Integer hour ) {

        String cronExpression = '0 0 ' + hour + ' ? * ' + dayOfWeek.name();

        schedule ( service, cronExpression );
    }

    public void abort ( String jobName ) {
        for ( CronTrigger cron : findJobsByName(jobName) ) {
            System.abortJob( cron.id );
        }
    }

    public List<CronTrigger> findJobsByName ( String jobName ) {
        return [SELECT Id , CronJobDetail.Name from CronTrigger where CronJobDetail.Name like : (jobName + '%') ];
    }

    @TestVisible
    private String getServiceName( Schedulable service ) {
        return String.valueOf(service).substring(0, String.valueOf(service).indexOf(':'));
    }
}