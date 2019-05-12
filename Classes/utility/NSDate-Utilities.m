/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook 3.x and beyond
 BSD License, Use at your own risk
 */

/*
 #import <humor.h> : Not planning to implement: dateByAskingBoyOut and dateByGettingBabysitter
 ----
 General Thanks: sstreza, Scott Lawrence, Kevin Ballard, NoOneButMe, Avi`, August Joki. Emanuele Vulcano, jcromartiej, Blagovest Dachev, Matthias Plappert,  Slava Bushtruk, Ali Servet Donmez, Ricardo1980, pip8786, Danny Thuerin, Dennis Madsen
*/

#import "NSDate-Utilities.h"

#define DATE_COMPONENTS (NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit |  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit)
#define CURRENT_CALENDAR [NSCalendar currentCalendar]

static NSDateFormatter *formatter = nil;

@implementation NSDate (Utilities)

#pragma mark Relative Dates

+ (NSDate *) dateWithDaysFromNow: (NSInteger) days
{
    // Thanks, Jim Morrison
	return [[NSDate date] dateByAddingDays:days];
}

+ (NSDate *) dateWithDaysBeforeNow: (NSInteger) days
{
    // Thanks, Jim Morrison
	return [[NSDate date] dateBySubtractingDays:days];
}

+ (NSDate *) dateTomorrow
{
	return [NSDate dateWithDaysFromNow:1];
}

+ (NSDate *) dateYesterday
{
	return [NSDate dateWithDaysBeforeNow:1];
}

+ (NSDate *) dateWithHoursFromNow: (NSInteger) dHours
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_HOUR * dHours;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;	
}

+ (NSDate *) dateWithHoursBeforeNow: (NSInteger) dHours
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_HOUR * dHours;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;	
}

+ (NSDate *) dateWithMinutesFromNow: (NSInteger) dMinutes
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;		
}

+ (NSDate *) dateWithMinutesBeforeNow: (NSInteger) dMinutes
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_MINUTE * dMinutes;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;		
}

#pragma mark Comparing Dates

- (BOOL) isEqualToDateIgnoringTime: (NSDate *) aDate
{
	NSDateComponents *components1 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	NSDateComponents *components2 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate];
	return ((components1.year == components2.year) &&
			(components1.month == components2.month) && 
			(components1.day == components2.day));
}

- (BOOL) isToday
{
	return [self isEqualToDateIgnoringTime:[NSDate date]];
}

- (BOOL) isTomorrow
{
	return [self isEqualToDateIgnoringTime:[NSDate dateTomorrow]];
}

- (BOOL) isYesterday
{
	return [self isEqualToDateIgnoringTime:[NSDate dateYesterday]];
}

// This hard codes the assumption that a week is 7 days
- (BOOL) isSameWeekAsDate: (NSDate *) aDate
{
	NSDateComponents *components1 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	NSDateComponents *components2 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate];
	
	// Must be same week. 12/31 and 1/1 will both be week "1" if they are in the same week
	if (components1.week != components2.week) return NO;
	
	// Must have a time interval under 1 week. Thanks @aclark
	return (abs([self timeIntervalSinceDate:aDate]) < D_WEEK);
}

- (BOOL) isThisWeek
{
	return [self isSameWeekAsDate:[NSDate date]];
}

- (BOOL) isNextWeek
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_WEEK;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return [self isSameWeekAsDate:newDate];
}

- (BOOL) isLastWeek
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_WEEK;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return [self isSameWeekAsDate:newDate];
}

// Thanks, mspasov
- (BOOL) isSameMonthAsDate: (NSDate *) aDate
{
    NSDateComponents *components1 = [CURRENT_CALENDAR components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:aDate];
    return ((components1.month == components2.month) &&
            (components1.year == components2.year));
}

- (BOOL) isThisMonth
{
    return [self isSameMonthAsDate:[NSDate date]];
}

- (BOOL) isSameYearAsDate: (NSDate *) aDate
{
	NSDateComponents *components1 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:self];
	NSDateComponents *components2 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:aDate];
	return (components1.year == components2.year);
}

- (BOOL) isThisYear
{
    // Thanks, baspellis
	return [self isSameYearAsDate:[NSDate date]];
}

- (BOOL) isNextYear
{
	NSDateComponents *components1 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:self];
	NSDateComponents *components2 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:[NSDate date]];
	
	return (components1.year == (components2.year + 1));
}

- (BOOL) isLastYear
{
	NSDateComponents *components1 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:self];
	NSDateComponents *components2 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:[NSDate date]];
	
	return (components1.year == (components2.year - 1));
}

- (BOOL) isEarlierThanDate: (NSDate *) aDate
{
	return ([self compare:aDate] == NSOrderedAscending);
}

- (BOOL) isLaterThanDate: (NSDate *) aDate
{
	return ([self compare:aDate] == NSOrderedDescending);
}

// Thanks, markrickert
- (BOOL) isInFuture
{
    return ([self isLaterThanDate:[NSDate date]]);
}

// Thanks, markrickert
- (BOOL) isInPast
{
    return ([self isEarlierThanDate:[NSDate date]]);
}


#pragma mark Roles
- (BOOL) isTypicallyWeekend
{
    NSDateComponents *components = [CURRENT_CALENDAR components:NSWeekdayCalendarUnit fromDate:self];
    if ((components.weekday == 1) ||
        (components.weekday == 7))
        return YES;
    return NO;
}

- (BOOL) isTypicallyWorkday
{
    return ![self isTypicallyWeekend];
}

#pragma mark Adjusting Dates

- (NSDate *) dateByAddingDays: (NSInteger) dDays
{
	NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_DAY * dDays;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;		
}

- (NSDate *) dateBySubtractingDays: (NSInteger) dDays
{
	return [self dateByAddingDays: (dDays * -1)];
}

- (NSDate *) dateByAddingHours: (NSInteger) dHours
{
	NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_HOUR * dHours;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;		
}

- (NSDate *) dateBySubtractingHours: (NSInteger) dHours
{
	return [self dateByAddingHours: (dHours * -1)];
}

- (NSDate *) dateByAddingMinutes: (NSInteger) dMinutes
{
	NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;			
}

- (NSDate *) dateBySubtractingMinutes: (NSInteger) dMinutes
{
	return [self dateByAddingMinutes: (dMinutes * -1)];
}

- (NSDate *) dateAtStartOfDay
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	components.hour = 0;
	components.minute = 0;
	components.second = 0;
	return [CURRENT_CALENDAR dateFromComponents:components];
}

- (NSDateComponents *) componentsWithOffsetFromDate: (NSDate *) aDate
{
	NSDateComponents *dTime = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate toDate:self options:0];
	return dTime;
}

#pragma mark Retrieving Intervals

- (NSInteger) minutesAfterDate: (NSDate *) aDate
{
	NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
	return (NSInteger) (ti / D_MINUTE);
}

- (NSInteger) minutesBeforeDate: (NSDate *) aDate
{
	NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
	return (NSInteger) (ti / D_MINUTE);
}

- (NSInteger) hoursAfterDate: (NSDate *) aDate
{
	NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
	return (NSInteger) (ti / D_HOUR);
}

- (NSInteger) hoursBeforeDate: (NSDate *) aDate
{
	NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
	return (NSInteger) (ti / D_HOUR);
}

- (NSInteger) daysAfterDate: (NSDate *) aDate
{
	NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
	return (NSInteger) (ti / D_DAY);
}

- (NSInteger) daysBeforeDate: (NSDate *) aDate
{
	NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
	return (NSInteger) (ti / D_DAY);
}

// Thanks, dmitrydims
// I have not yet thoroughly tested this
- (NSInteger)distanceInDaysToDate:(NSDate *)anotherDate
{
    NSCalendar *gregorianCalendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit fromDate:self toDate:anotherDate options:0];
    return components.day;
}

#pragma mark Decomposing Dates

- (NSInteger) nearestHour
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_MINUTE * 30;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	NSDateComponents *components = [CURRENT_CALENDAR components:NSHourCalendarUnit fromDate:newDate];
	return components.hour;
}

- (NSInteger) hour
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return components.hour;
}

- (NSInteger) minute
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return components.minute;
}

- (NSInteger) seconds
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return components.second;
}

- (NSInteger) day
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return components.day;
}

- (NSInteger) month
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return components.month;
}

- (NSInteger) week
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return components.week;
}

- (NSInteger) weekday
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return components.weekday;
}

- (NSInteger) nthWeekday // e.g. 2nd Tuesday of the month is 2
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return components.weekdayOrdinal;
}

- (NSInteger) year
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return components.year;
}

+ (NSString *)dbFormatString {
	return @"yyyy-MM-dd HH:mm:ss";
}

+ (NSString *)newsDateFormatString {
    return @"yyyy-MM-dd HH:mm";
}


+ (NSDate *)dateFromString:(NSString *)string {
    if (!string) {
        return nil;
    }
    NSDate *newDate = [NSDate dateFromString:string withFormat:[NSDate newsDateFormatString]];
    if (!newDate) {
        newDate = [NSDate dateFromString:string withFormat:[NSDate dbFormatString]];
    }
	return newDate;
}

+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format {
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
    }
	[formatter setDateFormat:format];
	NSDate *date = [formatter dateFromString:string];
	return date;
}

+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)format {
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
    }
	[formatter setDateFormat:format];
	NSString *timestamp_str = [formatter stringFromDate:date];
	return timestamp_str;
}

+ (NSString *)weekStringFromDate:(NSDate *)date {
    NSDateFormatter *dateFromatter = [[NSDateFormatter alloc] init];
    NSLocale *cnLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    [dateFromatter setLocale:cnLocale];
    [dateFromatter setDateFormat:@"yyyy.MM.dd  EEEE"];
	NSString *weekDateString = [dateFromatter stringFromDate:date];
    [cnLocale release];
    [dateFromatter release];
    return weekDateString;
}

+(NSString *)localWeatherDateStringFromDate:(NSDate *)date {
    NSDateFormatter *dateFromatter = [[NSDateFormatter alloc] init];
    NSLocale *cnLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    [dateFromatter setLocale:cnLocale];
    [dateFromatter setDateFormat:@"MM月dd日 EEEE"];
	NSString *weekDateString = [dateFromatter stringFromDate:date];
    [cnLocale release];
    [dateFromatter release];
    return weekDateString;
}

+ (NSString *)stringFromDoubleDateString:(NSString *)dateString {
    if ([dateString length] > 0) {
        NSDate *dateParam = [NSDate dateWithTimeIntervalSince1970:[dateString doubleValue]/1000];
        return [self stringFromDate:dateParam withFormat:@"yyyy-MM-dd HH:mm"];
    }
    return @"";
}

+ (NSString *)stringFromDate:(NSDate *)date {
	return [NSDate stringFromDate:date withFormat:[NSDate dbFormatString]];
}

+ (NSDate*) convertToGMT:(NSDate*)sourceDate {
    //NSTimeZone* currentTimeZone = [NSTimeZone localTimeZone];
    //    NSTimeInterval gmtInterval = [currentTimeZone secondsFromGMTForDate:sourceDate];
    //    NSDate* destinationDate = [[[NSDate alloc] initWithTimeInterval:gmtInterval sinceDate:sourceDate] autorelease];
    //    return destinationDate;
	NSTimeInterval timeZoneOffset = [[NSTimeZone defaultTimeZone] secondsFromGMT]; // You could also use the systemTimeZone method
	NSTimeInterval gmtTimeInterval = [sourceDate timeIntervalSinceReferenceDate] - timeZoneOffset;
	return [NSDate dateWithTimeIntervalSinceReferenceDate:gmtTimeInterval];
	
}

+(BOOL)isSameDayWithDateString:(NSString *) dateString anotherDateStirng:(NSString *) anotherString {
    
    if (!dateString || !anotherString) {
        return NO;
    }
    
    NSDate *date= [self dateFromString:dateString];
    NSDate *anotherDate = [self dateFromString:anotherString];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [gregorian components:
                                        (NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit)
                                                    fromDate:date];
    NSDateComponents *anotherDateComponents = [gregorian components:
                                               (NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit)
                                                           fromDate:anotherDate];
    [gregorian release];
    
    if (dateComponents.year == anotherDateComponents.year &&
        dateComponents.month == anotherDateComponents.month && dateComponents.day == anotherDateComponents.day) {
        return YES;
    }else {
        return NO;
    }
    
}


+ (NSString *)relativelyDate:(NSString *)doubleString
{
	if (doubleString.length > 0 && ![doubleString isEqualToString:@"0"])
    {
        NSDate *dateParam = [NSDate dateWithTimeIntervalSince1970:[doubleString doubleValue]/1000];
		double interval = [dateParam timeIntervalSinceNow]*-1;
        
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *compsToday = [gregorian components:
                                        (NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit)
                                                    fromDate:[NSDate date]];
        NSDateComponents *compsDate = [gregorian components:
                                       (NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit)
                                                   fromDate:dateParam];
        [gregorian release];
        
        
		if (interval > 0)
        {
            /*if (interval < 60) {
             return [NSString stringWithFormat:@"%d秒前",(int)interval];
             } else
             */
            if (compsToday.year == compsDate.year)
            {
                if(interval < 60)
                    return @"刚刚";
                else if(interval < 3600)
                {
                    return [NSString stringWithFormat:@"%d分钟前",(int)round(interval/60)];
                }
                else if(interval < 60*60*24)
                {
                    return [NSString stringWithFormat:@"%d小时前",(int)round(interval/60/60)];
                }
                else
                {
                    return [NSDate stringFromDate:dateParam withFormat:@"yyyy/MM/dd"];
                }
            }
            else
            {
				return [NSDate stringFromDate:dateParam withFormat:@"yyyy/MM/dd"];
			}
		}
        else
        {
            // 如果是未来的时间  说明手机设置的时间 有问题 比真实的时间要慢  这种情况 特殊处理一下 替代直接返回空字符串的做法 by jojo
            if (compsToday.year == compsDate.year)
            {
                if (compsToday.month == compsDate.month && compsToday.day == compsDate.day)
                {
                    return [NSDate stringFromDate:dateParam withFormat:@"HH:mm"];
                }
                else
                {
                    return [NSDate stringFromDate:dateParam withFormat:@"MM-dd"];
                }
            }
            else
            {
				return [NSDate stringFromDate:dateParam withFormat:@"yyyy-MM-dd"];
            }
		}
        
	}
    else
    {
		return @"";
	}
}

+ (NSString *)accessoryRelativelyDate:(NSString *)doubleString {
	if (doubleString) {
        NSDate *dateParam = [NSDate dateWithTimeIntervalSince1970:[doubleString doubleValue]/1000];
		double interval = [dateParam timeIntervalSinceNow]*-1;
        
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *compsToday = [gregorian components:
                                        (NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit)
                                                    fromDate:[NSDate date]];
        NSDateComponents *compsDate = [gregorian components:
                                       (NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit)
                                                   fromDate:dateParam];
        [gregorian release];
        
        
		if (interval > 0) {
            /*if (interval < 60) {
             return [NSString stringWithFormat:@"%d秒前",(int)interval];
             } else
             */
            if (compsToday.year == compsDate.year && compsToday.month == compsDate.month && compsToday.day == compsDate.day) {
                if(interval < 60)
                    return @"刚刚";
                else if(interval < 3600) {
                    return [NSString stringWithFormat:@"%d分钟前",(int)round(interval/60)];
                } else {
                    return [NSString stringWithFormat:@"%@", [NSDate stringFromDate:dateParam withFormat:@"HH点mm分"]];
                }
            } else {
				return [NSDate stringFromDate:dateParam withFormat:@"MM年dd月"];
			}
		} else {
			return @"";
		}
        
	} else {
		return @"";
	}
}

+ (NSString *)expressRelativelyDate:(NSString *)doubleString {
	if (doubleString.length > 0) {
        NSDate *dateParam = [NSDate dateWithTimeIntervalSince1970:[doubleString doubleValue]/1000];
		double interval = [dateParam timeIntervalSinceNow]*-1;
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *compsToday = [gregorian components:
                                        (NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit)
                                                    fromDate:[NSDate date]];
        NSDateComponents *compsDate = [gregorian components:
                                       (NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit)
                                                   fromDate:dateParam];
        [gregorian release];
		if (interval > 0) {
            if(interval < 60)
                return @"刚刚";
            else if(interval < 3600) {
                return [NSString stringWithFormat:@"%d分钟前",(int)round(interval/60)];
            } else if(interval < 24*3600){
                return [NSString stringWithFormat:@"%d小时前",(int)round(interval/60/60)];
            } else if(compsToday.year == compsDate.year){
                return [NSDate stringFromDate:dateParam withFormat:@"MM-dd"];
            }else {
                return [NSDate stringFromDate:dateParam withFormat:@"yyyy-MM-dd"];
            }
		} else {
			return @"";
		}
	} else {
		return @"";
	}
}


+ (NSString *)getLiveDateWithString:(NSString *)doubleString {
    NSString *dateString = @"";
	if (doubleString.length >0 && ![doubleString isEqualToString:@"0"]) {
        NSDate *dateParam = [NSDate dateWithTimeIntervalSince1970:[doubleString doubleValue]/1000];
        dateString = [NSDate stringFromDate:dateParam withFormat:@"MM月dd日 HH:mm"];
	}
    return dateString;
}

//now time interval number
+ (NSNumber *)nowTimeIntervalNumber {
    NSDate *_nowDate = [NSDate date];
    return [NSNumber numberWithInt:[_nowDate timeIntervalSince1970]];
}

//获取系统时间
+ (NSNumber *)nowDateToSysytemIntervalNumber {
    NSDate *_nowDate = [SNUtility changeNowDateToSysytemDate:[NSDate date]];
    return [NSNumber numberWithInt:[_nowDate timeIntervalSince1970]];
}


- (NSString*)formatTimeWithType:(int)type {
    static NSCalendar *gregorian = nil;
    if (gregorian == nil) {
        gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    }
    
    static NSDateFormatter* formatter = nil;
    if (nil == formatter) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = TTCurrentLocale();
    }
    
    NSString *formatStr = nil;
    
    NSDateComponents *compsToday = [gregorian components:
                                    (NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit)
                                                fromDate:[NSDate date]];
    NSDateComponents *compsDate = [gregorian components:
                                   (NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit)
                                               fromDate:self];
    
    if (compsToday.year == compsDate.year) {
        if (compsToday.month == compsDate.month && compsToday.day == compsDate.day) {
            //同一天 显示hh:mm:ss
            if (type == 1) {
                formatStr = @"HH:mm";
            } else {
                formatStr = @"HH:mm:ss";
            }
            formatter.dateFormat = formatStr;
            return [formatter stringFromDate:self];
        } else {
            //非同一天 显示MM/dd hh:mm:ss
            if (type == 1) {
                formatStr = @"MM月dd日";
            } else {
                formatStr = @"MM/dd HH:mm:ss";
            }
            formatter.dateFormat = formatStr;
            return [formatter stringFromDate:self];
        }
    } else {
        // 不是同一年
        if (type == 1) {
            formatStr = @"MM月dd日";
        } else {
            formatStr = @"MM/dd HH:mm:ss";
        }
        formatter.dateFormat = formatStr;
        return [formatter stringFromDate:self];
    }
}

- (NSString*)formatTimeString {
    return [self formatTimeWithType:0];
}

- (NSString*)accessoryFormatTimeWithType:(int)type {
    
    static NSCalendar *gregorian = nil;
    if (gregorian == nil) {
        gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    }
    
    static NSDateFormatter* formatter = nil;
    if (nil == formatter) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = TTCurrentLocale();
    }
    
    NSString *formatStr = nil;
    
	NSDateComponents *compsToday = [gregorian components:
                                    (NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit)
                                                fromDate:[NSDate date]];
    NSDateComponents *compsDate = [gregorian components:
                                   (NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit)
                                               fromDate:self];
    
    if (compsToday.year == compsDate.year) {
        if (compsToday.month == compsDate.month && compsToday.day == compsDate.day) {
            //同一天 显示hh:mm:ss
            if (type == 1) {
                formatStr = @"HH点mm分";
            } else {
                formatStr = @"HH点mm分ss秒";
            }
            formatter.dateFormat = formatStr;
            return [formatter stringFromDate:self];
        } else {
            //非同一天 显示MM/dd hh:mm:ss
            if (type == 1) {
                formatStr = @"MM月dd日";
            } else {
                formatStr = @"MM月dd日 HH点mm分ss秒";
            }
            formatter.dateFormat = formatStr;
            return [formatter stringFromDate:self];
        }
    } else {
        // 不是同一年
        if (type == 1) {
            formatStr = @"MM月dd日";
        } else {
            formatStr = @"yyyy年MM月dd日 HH点mm分ss秒";
        }
        formatter.dateFormat = formatStr;
        return [formatter stringFromDate:self];
    }
}

- (NSString*)accessoryFormatTimeString {
    return [self accessoryFormatTimeWithType:0];
}

@end
