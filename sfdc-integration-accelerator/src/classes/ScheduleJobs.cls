/**
 * @description: This utility class is used to schedule jobs.
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

    public void intoNextMinutes ( Schedulable service, Integer minutes ) {

        String baseExpression = ' * * ?';

        Datetime nextScheduleTime = System.now().addMinutes(minutes);

        String cron = '0 ' + nextScheduleTime.minute() + ' ' + nextScheduleTime.hour() + baseExpression;

        this.forExpression( service, cron );
    }

    public void forExpression ( Schedulable service, String expression ) {
        System.schedule( getServiceName (service) + '  ' + jobCountForTest + expression, expression, service );
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